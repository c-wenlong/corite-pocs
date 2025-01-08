from typing import Dict, List, Optional
from neo4j import GraphDatabase
from datetime import datetime
import logging
import json


class Neo4jDatabase:
    def __init__(self, uri: str, username: str, password: str):
        self.driver = GraphDatabase.driver(uri, auth=(username, password))
        self._init_constraints()

    def _init_constraints(self):
        """Initialize constraints for the Session nodes."""
        with self.driver.session() as session:
            # Create constraints
            session.run(
                """
                CREATE CONSTRAINT session_id IF NOT EXISTS
                FOR (s:Session) REQUIRE s.id IS UNIQUE
            """
            )

            session.run(
                """
                CREATE CONSTRAINT category_name IF NOT EXISTS
                FOR (c:Category) REQUIRE c.name IS UNIQUE
            """
            )

    def create_session_node(self, session_data: Dict):
        """Create a session node with all its relationships."""
        with self.driver.session() as session:
            # Create session node
            session.run(
                """
                MERGE (s:Session {id: $id})
                SET s.name = $name,
                    s.category = $category,
                    s.summary = $summary,
                    s.demographic = $demographic,
                    s.lastUpdated = datetime()
                
                WITH s
                
                // Create Category relationship
                MERGE (c:Category {name: $category})
                MERGE (s)-[:IN_CATEGORY]->(c)
                
                // Create Keywords
                WITH s
                UNWIND $keywords AS keyword
                MERGE (k:Keyword {name: keyword})
                MERGE (s)-[:HAS_KEYWORD]->(k)
                
                // Create Interests
                WITH s
                UNWIND $interests AS interest
                MERGE (i:Interest {name: interest})
                MERGE (s)-[:TARGETS_INTEREST]->(i)
                
                // Create Preferences
                WITH s
                UNWIND $preferences AS preference
                MERGE (p:Preference {name: preference})
                MERGE (s)-[:HAS_PREFERENCE]->(p)
            """,
                {
                    "id": session_data["id"],
                    "name": session_data.get("name", ""),
                    "category": session_data["category"],
                    "summary": session_data["summary"],
                    "demographic": session_data["intended_target_audience"][
                        "demographic"
                    ],
                    "keywords": session_data["keywords"],
                    "interests": session_data["intended_target_audience"]["interests"],
                    "preferences": session_data["intended_target_audience"][
                        "preferences"
                    ],
                },
            )

    def create_similarity_relationships(
        self, session_id: int, similar_sessions: List[Dict], similarity_score: float
    ):
        """Create SIMILAR_TO relationships between sessions based on vector similarity."""
        with self.driver.session() as session:
            session.run(
                """
                MATCH (s1:Session {id: $source_id})
                MATCH (s2:Session {id: $target_id})
                MERGE (s1)-[r:SIMILAR_TO]->(s2)
                SET r.similarity_score = $similarity_score,
                    r.last_updated = datetime()
                RETURN s1, s2
            """,
                {
                    "source_id": session_id,
                    "target_id": similar_sessions["id"],
                    "similarity_score": similarity_score,
                },
            )

    def get_session_by_id(self, session_id: int) -> Optional[Dict]:
        """Retrieve complete session information by ID."""
        with self.driver.session() as session:
            result = session.run(
                """
                MATCH (s:Session {id: $id})
                OPTIONAL MATCH (s)-[:HAS_KEYWORD]->(k:Keyword)
                OPTIONAL MATCH (s)-[:TARGETS_INTEREST]->(i:Interest)
                OPTIONAL MATCH (s)-[:HAS_PREFERENCE]->(p:Preference)
                RETURN s,
                       collect(DISTINCT k.name) as keywords,
                       collect(DISTINCT i.name) as interests,
                       collect(DISTINCT p.name) as preferences
            """,
                {"id": session_id},
            )

            record = result.single()
            if record:
                session_node = record["s"]
                return {
                    "id": session_node["id"],
                    "name": session_node["name"],
                    "category": session_node["category"],
                    "summary": session_node["summary"],
                    "demographic": session_node["demographic"],
                    "keywords": record["keywords"],
                    "intended_target_audience": {
                        "demographic": session_node["demographic"],
                        "interests": record["interests"],
                        "preferences": record["preferences"],
                    },
                }
            return None

    def get_similar_sessions(self, session_id: int, limit: int = 5) -> List[Dict]:
        """Get similar sessions based on similarity relationships."""
        with self.driver.session() as session:
            result = session.run(
                """
                MATCH (s:Session {id: $id})-[r:SIMILAR_TO]->(similar:Session)
                RETURN similar.id as id,
                       similar.name as name,
                       similar.category as category,
                       r.similarity_score as similarity
                ORDER BY r.similarity_score DESC
                LIMIT $limit
            """,
                {"id": session_id, "limit": limit},
            )
            return [dict(record) for record in result]

    def get_sessions_by_category(self, category: str) -> List[Dict]:
        """Get all sessions in a specific category."""
        with self.driver.session() as session:
            result = session.run(
                """
                MATCH (s:Session)-[:IN_CATEGORY]->(c:Category {name: $category})
                RETURN s.id as id, s.name as name, s.summary as summary
            """,
                {"category": category},
            )
            return [dict(record) for record in result]

    def bulk_import_sessions(self, sessions_json: Dict):
        """Bulk import sessions from JSON data."""
        for session_name, session_data in sessions_json.items():
            # Add name to session data
            session_data["name"] = session_name
            self.create_session_node(session_data)

    def create_session_paths(self):
        """Create logical paths between sessions based on categories and prerequisites."""
        with self.driver.session() as session:
            # Example: Connect onboarding sessions to relevant next steps
            session.run(
                """
                MATCH (s1:Session {category: 'Onboarding'})
                MATCH (s2:Session)
                WHERE s2.category IN ['Marketing', 'Brand Development']
                AND NOT (s1)-[:LEADS_TO]->(s2)
                CREATE (s1)-[:LEADS_TO {order: 1}]->(s2)
            """
            )

    def get_recommended_path(self, start_session_id: int, steps: int = 3) -> List[Dict]:
        """Get recommended session path starting from a given session."""
        with self.driver.session() as session:
            result = session.run(
                """
                MATCH path = (start:Session {id: $id})-[:LEADS_TO*1..3]->(next:Session)
                WITH path, relationships(path) as rels
                RETURN [node in nodes(path) | {
                    id: node.id,
                    name: node.name,
                    category: node.category,
                    summary: node.summary
                }] as path_nodes,
                [rel in rels | rel.order] as steps
                ORDER BY length(path), reduce(s = 0, rel in rels | s + rel.order)
                LIMIT 1
            """,
                {"id": start_session_id},
            )
            paths = [record["path_nodes"] for record in result]
            return paths[0] if paths else []

    def close(self):
        """Close the database driver."""
        self.driver.close()
