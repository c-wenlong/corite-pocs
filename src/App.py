import streamlit as st
from services import fetch_recommended_sessions
from services import user_to_vectordb_prompt
import os


def main():
    initalise_page_config()
    initialise_session_state()

    search, history = st.columns([3, 2])
    with search:
        st.markdown(
            "#### Describe your needs as an artist and I will recommend a session for you."
        )
        recommendation_engine()
    with history:
        display_history()


def initalise_page_config():
    st.set_page_config(
        layout="wide", initial_sidebar_state="collapsed", page_title="Aflow Recommends"
    )


def initialise_session_state():
    if "query_history" not in st.session_state:
        st.session_state["query_history"] = []


def recommendation_engine():
    # Create input field
    prompt = st.text_input(
        "Try using the prompt below! \n\n The artist wants a session to boost his spotify bio, so that he can gain a larger following on spotify, he also wants to create a press release for his next single, coming out in just 2 weeks."
    )

    # Add a submit button
    if st.button("Get Recommendations"):
        if prompt:
            with st.spinner("Finding recommendations..."):
                improved_prompt = user_to_vectordb_prompt(prompt)
                response = fetch_recommended_sessions(improved_prompt)

                # Create cards for each recommendation
                for session in response:
                    with st.container():
                        st.markdown(
                            f"""
                            <div style="
                                padding: 20px;
                                border-radius: 10px;
                                margin: 10px 0px;
                                background-color: #f0f2f6;
                                border-left: 5px solid #ff4b4b;
                                box-shadow: 0 1px 2px rgba(0,0,0,0.1);">
                                <h3 style="margin: 0; color: #333;">{session}</h3>
                            </div>
                            """,
                            unsafe_allow_html=True,
                        )
            st.session_state["query_history"].append(
                {"prompt": prompt, "response": response}
            )
        else:
            st.warning("Please enter your needs first.")

    if st.button("Load Artist Data"):
        artist = load_json()
        with st.spinner("Finding recommendations..."):
            improved_prompt = user_to_vectordb_prompt(artist)
            response = fetch_recommended_sessions(improved_prompt)

            # Create cards for each recommendation
            for session in response:
                with st.container():
                    st.markdown(
                        f"""
                        <div style="
                            padding: 20px;
                            border-radius: 10px;
                            margin: 10px 0px;
                            background-color: #f0f2f6;
                            border-left: 5px solid #ff4b4b;
                            box-shadow: 0 1px 2px rgba(0,0,0,0.1);">
                            <h3 style="margin: 0; color: #333;">{session}</h3>
                        </div>
                        """,
                        unsafe_allow_html=True,
                    )
        st.session_state["query_history"].append(
            {"prompt": improved_prompt, "response": response}
        )


def load_json(filepath="./src/assets/artists/justin_bieber.json"):
    try:
        # Check if file exists
        if not os.path.exists(filepath):
            raise FileNotFoundError(f"The file {filepath} does not exist")

        # Read file as string
        with open(filepath, "r", encoding="utf-8") as file:
            return file.read()

    except Exception as e:
        raise Exception(f"Error reading {filepath}: {str(e)}")


def display_history():
    # Display query history in a simple card
    if st.session_state.query_history:
        st.markdown("### Previous Searches")
        for idx, entry in enumerate(reversed(st.session_state.query_history), 1):
            prompt = entry["prompt"]
            response = entry["response"]
            st.markdown(
                f"""
               <div style="
                   padding: 12px 0;
                   border-bottom: 1px solid #eee;">
                   <p style="margin: 0 0 8px 0; color: #666;">
                       {idx}. {prompt}
                   </p>
                   <div style="display: flex; flex-wrap: wrap; gap: 6px;">
                       {' '.join([
                           f'<span style="background: #f0f0f0; padding: 2px 8px; border-radius: 12px; font-size: 14px; font-weight: bold; color: #666;">{chip}</span>'
                           for chip in response
                       ])}
                   </div>
               </div>
               """,
                unsafe_allow_html=True,
            )
    else:
        st.info("No previous searches yet.")


if __name__ == "__main__":
    main()
