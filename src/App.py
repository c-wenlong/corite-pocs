import streamlit as st

st.set_page_config(layout="centered", initial_sidebar_state="collapsed")


def main():
    st.title("Aflow PoCs")
    st.markdown(
        '''
        Here lies all projects related to Corite Aflow, all of which are proof of concept for real features to be implemented later on. \n
        #### Session Recommender: Recommends sessions to users based on user prompt or artist data. \n
        #### Text To Video: Generate videos from text
        '''
    )


if __name__ == "__main__":
    main()
