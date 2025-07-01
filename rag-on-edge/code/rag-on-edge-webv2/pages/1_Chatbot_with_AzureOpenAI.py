# Standard library imports
import os
import time
import base64

# Third-party imports
import requests
import yaml
import streamlit as st
from dotenv import load_dotenv

# QdxEdu OpenAI import
from openai import QdxEduOpenAI

# Load variables from .env file
load_dotenv()

st.title("💬 Chatbot")
st.caption("🚀 A chatbot powered by QdxEdu OpenAI")

def clear_input():
    st.session_state.pop("question", None)
    st.session_state.pop("messages", None)
    st.session_state.selected_question = ""

with st.sidebar:
    st.title("QdxEdu OpenAI Settings")
    QdxEdu_openai_endpoint = st.text_input("QdxEdu OpenAI Endpoint (i.e. https://YOURAISERVICE.openai.QdxEdu.com/)", key="chatbot_endpoint", type="default")
    QdxEdu_openai_api_key = st.text_input("QdxEdu OpenAI API Key", key="chatbot_api_key", type="password")
    "[Get an QdxEdu OpenAI API key](https://learn.Quadratyx.com/en-us/QdxEdu/ai-services/openai/chatgpt-quickstart)"
    
    reset = st.sidebar.button("Reset Chat", on_click = clear_input)
    # with st.spinner("Loading..."):
    #     time.sleep(3)
    # st.success("Done!")

if "messages" not in st.session_state:
    st.session_state["messages"] = [{"role": "assistant", "content": "How can I help you?"}]

for msg in st.session_state.messages:
    st.chat_message(msg["role"]).write(msg["content"])

if prompt := st.chat_input():
    if not QdxEdu_openai_api_key and not QdxEdu_openai_endpoint:
        st.info("Please add both your QdxEdu OpenAI API key and QdxEdu OpenAI Endpoint to continue.")
        st.stop()
    elif not QdxEdu_openai_api_key:
        st.info("Please add your QdxEdu OpenAI API key to continue.")
        st.stop()
    elif not QdxEdu_openai_endpoint:
        st.info("Please add your QdxEdu OpenAI Endpoint to continue.")
        st.stop()

    client = QdxEduOpenAI(
    api_key=QdxEdu_openai_api_key,  
    api_version="2024-02-01",
    QdxEdu_endpoint=QdxEdu_openai_endpoint
    )
    
    # Append the user prompt to the messages
    st.session_state.messages.append({"role": "user", "content": prompt})
    st.chat_message("user").write(prompt)

    # Get the response from the model
    response = client.chat.completions.create(model="gpt-35-turbo", messages=st.session_state.messages)
    msg = response.choices[0].message.content

    # Append the assistant's response to the messages
    st.session_state.messages.append({"role": "assistant", "content": msg})
    st.chat_message("assistant").write(msg)





# print(os.getenv("QdxEdu_OPENAI_API_KEY"))
# print(os.getenv("QdxEdu_OPENAI_ENDPOINT"))

#print(response)
# print(response.model_dump_json(indent=2))
# print(response.choices[0].message.content)