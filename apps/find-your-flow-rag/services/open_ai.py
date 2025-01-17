from openai import OpenAI
import streamlit as st

from .prompts import SYSTEM

OPENAI_API_KEY = st.secrets["OPENAI"]["OPENAI_API_KEY"]
openai_client = OpenAI(api_key=OPENAI_API_KEY)


def user_to_qdrant_prompt(user_prompt) -> str:
    completion = openai_client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": SYSTEM},
            {"role": "user", "content": user_prompt},
        ],
    )
    return completion.choices[0].message.content


def sessions_to_flow(sessions: list[str]):
    completion = openai_client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role": "user",
                "content": "I want you to arrange these sessions in a logical order separated by comma, only return the sessions and nothing else: \n\n".join(
                    sessions
                ),
            }
        ],
    )
    return completion.choices[0].message.content


def text_to_embedding(text):
    embeddings = openai_client.embeddings.create(
        model="text-embedding-3-small", input=text, encoding_format="float"
    )
    return embeddings.data[0].embedding


def test_connection():
    return openai_client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "system", "content": "Hello"}],
    )


if __name__ == "__main__":
    response = test_connection()
    print(response.choices[0].message.content)
