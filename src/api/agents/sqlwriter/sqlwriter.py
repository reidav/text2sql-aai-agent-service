import os
import sys
import json

from dotenv import load_dotenv
import prompty
import prompty.azure
from pathlib import Path
from prompty.tracer import trace
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential
from azure.ai.inference.prompts import PromptTemplate

load_dotenv()

# Create an Azure AI Client from a connection string, copied from your Azure AI Foundry project.
# At the moment, it should be in the format "<HostName>;<AzureSubscriptionId>;<ResourceGroup>;<HubName>"
# Customer needs to login to Azure subscription via Azure CLI and set the environment variables

@trace
def execute_sqlwriter(question: str, db_insights_context: str, feedback: str = "No feedback"):

    ai_project_conn_str = os.getenv("AZURE_LOCATION")+".api.azureml.ms;"+os.getenv("AZURE_SUBSCRIPTION_ID")+";"+os.getenv("AZURE_RESOURCE_GROUP")+";"+os.getenv("AZURE_AI_PROJECT_NAME")

    project_client = AIProjectClient.from_connection_string(
        credential=DefaultAzureCredential(),
        conn_str=ai_project_conn_str,
    )

    prompt_template = PromptTemplate.from_prompty(file_path="sqlwriter.prompty")
    messages = prompt_template.create_messages(question=question, db_insights_context=db_insights_context, feedback=feedback)

    # Create agent with the search tool and process assistant run
    with project_client:
        agent = project_client.agents.create_agent(
            model="gpt-4",
            name="t2sql-sqlwriter",
            instructions=messages[0]['content'],
            headers={"x-ms-enable-preview": "true"},
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

        print("Agent created and now doing sql writing...")
        print('')

        if run.status == "failed":
            print(f"Run failed: {run.last_error}")

        # Delete the assistant when done
        project_client.agents.delete_agent(agent.id)
        print("Deleted agent")

        # Fetch and log all messages
        messages = project_client.agents.list_messages(thread_id=thread.id)
        print(f"Messages: {messages}")

        sql_query_response = messages.data[0]['content'][0]['text']['value']
        try: 
            sql_query = json.loads(sql_query_response)
            print("SQL writer agent succesfully completed")
            return sql_query
        except Exception as ex:
            print(f'SQL writer agent failed: {str(ex)}')

        return None

@trace
def suggest_sql_query(question: str, db_insights_context: str):
    sql_query = execute_sqlwriter(question=question, db_insights_context=db_insights_context)
    print(sql_query)
    return sql_query

if __name__ == "__main__":
    from dotenv import load_dotenv

    load_dotenv()
    
    base = Path(__file__).parent

    # Get command line arguments
    if len(sys.argv) < 2:
        question = "Show me the latest market data from Apple ?"
    else:
        question = sys.argv[1]
    
    database_insight = json.loads(Path(base / "db-insights.json").read_text())

    sql_output = execute_sqlwriter(question=question, db_insights_context=database_insight)
    print(sql_output)