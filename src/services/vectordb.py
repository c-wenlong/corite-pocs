import streamlit as st
from dotenv import load_dotenv

load_dotenv()

from qdrant_client import QdrantClient, models

QDRANT_URL = st.secrets["QDRANT"]["QDRANT_URL"]
QDRANT_API_KEY = st.secrets["QDRANT"]["QDRANT_API_KEY"]
QDRANT_COLLECTION_NAME = st.secrets["QDRANT"]["COLLECTION_NAME"]

qdrant_client = QdrantClient(
    url=QDRANT_URL,
    api_key=QDRANT_API_KEY,
)

from openai import OpenAI

OPENAI_API_KEY = st.secrets["OPENAI"]["OPENAI_API_KEY"]
openai_client = OpenAI(api_key=OPENAI_API_KEY)


def text_to_embedding(text):
    embeddings = openai_client.embeddings.create(
        model="text-embedding-3-small", input=text, encoding_format="float"
    )
    return embeddings.data[0].embedding


def fetch_recommended_sessions(
    artist_profile, collection_name=QDRANT_COLLECTION_NAME, limit=5
):
    artist_embedding = text_to_embedding(artist_profile)
    similar_sessions = qdrant_client.search(
        collection_name=collection_name, query_vector=artist_embedding, limit=limit
    )
    return [session.payload["session_name"] for session in similar_sessions]


import json
from pathlib import Path


def read_json(file_path=Path("src/assets/datasets/session_metadata.json")):
    with open(file_path, "r") as file:
        sessions = json.load(file)
    return sessions


'''
# Creates qdrant vector database instance
qdrant_client.create_collection(
    collection_name=QDRANT_COLLECTION_NAME,
    vectors_config=models.VectorParams(size=1536, distance=models.Distance.COSINE)
)

# Convert the session metadata into embeddings
session_embeddings = {}
sessions = read_json()

# Iterate through each session
for session_name, session_data in sessions.items():
	# Convert session data to string for embedding
	session_text = f"""
	Category: {session_data['category']}
	Keywords: {', '.join(session_data['keywords'])}
	Summary: {session_data['summary']}
	Target Audience: {session_data['intended_target_audience']['demographic']}
	Interests: {', '.join(session_data['intended_target_audience']['interests'])}
	Preferences: {', '.join(session_data['intended_target_audience']['preferences'])}
	"""
	
	# Get embedding
	embedding = text_to_embedding(session_text)

	# Store result
	session_embeddings[session_name] = {
		'metadata': session_data,
		'embedding': embedding
	}

# Upload vector embeddings into QDRANT DB
from datetime import datetime

for idx, (session_name, session_data) in  enumerate(session_embeddings.items()):
	qdrant_client.upsert(
		collection_name=QDRANT_COLLECTION_NAME,
		points=[
			models.PointStruct(
				id=idx,
				payload={
					"session_name":session_name,
					"metadata":session_data["metadata"],
					"created_at":datetime.now().isoformat()
				},
				vector=session_data["embedding"]
			)
		]
	)
'''


def test():
    test_prompt = "The artist wants a session to boost his spotify bio, so that he can gain a larger following on spotify, he also wants to create a press release for his next single, coming out in just 2 weeks."
    recommendations = fetch_recommended_sessions(test_prompt)
    print(recommendations)
