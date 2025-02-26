import os
import sys
import json
from enum import Enum
from pydantic import BaseModel, TypeAdapter

from dotenv import load_dotenv
import tempfile
import prompty
import prompty.azure
from prompty.azure.processor import ToolCall
from prompty.tracer import trace
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential
from azure.ai.projects.models import CodeInterpreterTool, MessageRole, FilePurpose
from azure.ai.inference.prompts import PromptTemplate
from pathlib import Path

load_dotenv()

# Create an Azure AI Client from a connection string, copied from your Azure AI Foundry project.
# At the moment, it should be in the format "<HostName>;<AzureSubscriptionId>;<ResourceGroup>;<HubName>"
# Customer needs to login to Azure subscription via Azure CLI and set the environment variables

@trace
def execute_dataviz(question: str, sql_query: str, dataset: str):

    ai_project_conn_str = os.getenv("AZURE_LOCATION")+".api.azureml.ms;"+os.getenv("AZURE_SUBSCRIPTION_ID")+";"+os.getenv("AZURE_RESOURCE_GROUP")+";"+os.getenv("AZURE_AI_PROJECT_NAME")

    project_client = AIProjectClient.from_connection_string(
        credential=DefaultAzureCredential(),
        conn_str=ai_project_conn_str,
    )

    prompt_template = PromptTemplate.from_prompty(file_path="dataviz.prompty")
    messages = prompt_template.create_messages(question=question, sql_query=sql_query)

    # Create agent with the search tool and process assistant run
    with project_client:

        with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=True) as tmp_file:
            tmp_file.write(dataset)
            tmp_file.flush()
            print(f"Writing dataset to: {tmp_file.name}")
            csv_file = project_client.agents.upload_file_and_poll(
                file_path=tmp_file.name, purpose=FilePurpose.AGENTS
            )
            print(f"Uploaded file, file ID: {csv_file.id}")

            code_interpreter = CodeInterpreterTool(file_ids=[csv_file.id])

        agent = project_client.agents.create_agent(
            model="gpt-4",
            name="t2sql-dataviz",
            instructions=messages[0]['content'],
            headers={"x-ms-enable-preview": "true"},
            tools=code_interpreter.definitions,
            tool_resources=code_interpreter.resources,
        )

        print(f"Created agent, ID: {agent.id}")

        # Create thread for communication
        thread = project_client.agents.create_thread()
        print(f"Created thread, ID: {thread.id}")

        # Create message to thread
        message = project_client.agents.create_message(
            thread_id=thread.id,
            role="user",
            content=question,
        )
        print(f"Created message, ID: {message.id}")

        # Create and process agent run in thread with tools
        run = project_client.agents.create_and_process_run(thread_id=thread.id, assistant_id=agent.id)
        print(f"Run finished with status: {run.status}")

        print("Agent created and now researching...")
        print('')

        if run.status == "failed":
            print(f"Run failed: {run.last_error}")

        messages = project_client.agents.list_messages(thread_id=thread.id)
        print(f"Messages: {messages}")

        file_names = []

        for image_content in messages.image_contents:
            file_id = image_content.image_file.file_id
            print(f"Image File ID: {file_id}")
            file_name = f"{file_id}_image_file.png"
            project_client.agents.save_file(file_id=file_id, file_name=file_name, target_dir=Path.cwd() / "assets")
            print(f"Saved image file to: {Path.cwd() / "assets" / file_name}")
            file_names.append(file_name)            

        for file_path_annotation in messages.file_path_annotations:
            print("File Paths:")
            print(f"Type: {file_path_annotation.type}")
            print(f"Text: {file_path_annotation.text}")
            print(f"File ID: {file_path_annotation.file_path.file_id}")
            print(f"Start Index: {file_path_annotation.start_index}")
            print(f"End Index: {file_path_annotation.end_index}")
        # [END get_messages_and_save_files]

        message = ""
        last_msg = messages.get_last_message_by_sender(MessageRole.AGENT)
        if last_msg:
            message = last_msg.text_messages[0].text.value
            print(f"Last Message: {message}")

        # Delete the assistant when done
        project_client.agents.delete_agent(agent.id)
        print("Deleted agent")

        return {
            "query" : sql_query,
            "message" : message,
            "images" : file_names
        }

if __name__ == "__main__":
    base = Path(__file__).parent

    # Get command line arguments
    if len(sys.argv) < 2:
        question = "Show me the latest market data from Apple ? It should be a line chart."
    else:
        question = sys.argv[1]

    sql_query = "SELECT s.symbol, md.price_date, md.open_price, md.close_price, md.high_price, md.low_price, md.volume FROM market_data md JOIN securities s ON md.security_id = s.security_id WHERE s.symbol = 'AAPL';"

    dataset = Path(base / "dataset.json").read_text()

    dataviz = execute_dataviz(question=question, sql_query=sql_query, dataset=dataset)
    print(dataviz)