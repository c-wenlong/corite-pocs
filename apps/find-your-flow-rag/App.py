import streamlit as st

st.set_page_config(
    layout="centered", initial_sidebar_state="expanded", page_title="Aflow PoCs"
)


def main():
    st.title("Aflow PoCs")
    st.markdown(
        """
        Here lies all projects related to Corite Aflow, all of which are proof of concept for real features to be implemented later on. \n
        #### Session Recommender: Recommends sessions to users based on user prompt or artist data. \n
        #### Session Graph Visualizer: Visualizes all sessions in a graph format, mapping all dependencies, semantic similarities and traversal histories. \n
        """
    )


if __name__ == "__main__":
    main()
