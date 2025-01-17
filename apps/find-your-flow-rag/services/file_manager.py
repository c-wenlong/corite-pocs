import json
from pathlib import Path

DEAFULT_PATH = "apps/find-your-flow-rag/assets/datasets/session_metadata.json"


def read_json(file_path=Path(DEAFULT_PATH)):
    with open(file_path, "r") as file:
        sessions = json.load(file)
    return sessions


def parse_array_str(array_str):
    return [item.strip() for item in array_str.split(",")]
