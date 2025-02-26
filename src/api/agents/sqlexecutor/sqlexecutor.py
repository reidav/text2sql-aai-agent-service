import json
import os
import sys
from prompty.tracer import trace
from dotenv import load_dotenv, dotenv_values
from pathlib import Path
import pandas as pd
import pyodbc

load_dotenv()

# Create an Azure AI Client from a connection string, copied from your Azure AI Foundry project.
# At the moment, it should be in the format "<HostName>;<AzureSubscriptionId>;<ResourceGroup>;<HubName>"
# Customer needs to login to Azure subscription via Azure CLI and set the environment variables

@trace
def execute_sql(sql_query: str) -> list:

    print("Starting SQL executor agent ...")
    sql_connection_string = os.environ["AZURESQL_CONNECTIONSTRING"]
    
    result = {}
    try: 
        conn = pyodbc.connect(sql_connection_string)
        cursor = conn.cursor()

        print (f"Executing SQL query: {sql_query}")
        cursor.execute(sql_query)

        col_headers = [ i[0] for i in cursor.description ]
        rows = [ list(i) for i in cursor.fetchall()] 
        df = pd.DataFrame(rows, columns=col_headers)
        
        print (df)
        
        for col in df.columns:
            df[col] = df[col].astype(str)

        result = {
            "sql_query": sql_query,
            "status": "success",
            "error": "",
            "data": df.to_dict(orient='index')
            }
    except Exception as ex:
        print(f"SQL query failed: {repr(ex)}")
        result = {
            "sql_query": sql_query,
            "status": "failed",
            "error": json.dumps(repr(ex)),
            "data": ""
        }

    print (f"SQL query result: {result}")
    return result

if __name__ == "__main__":
    from dotenv import load_dotenv

    load_dotenv()

    # Get command line arguments
    if len(sys.argv) < 2:
        sql_query = "SELECT s.symbol, md.price_date, md.open_price, md.close_price, md.high_price, md.low_price, md.volume FROM market_data md JOIN securities s ON md.security_id = s.security_id WHERE s.symbol = 'AAPL'"
    else:
        sql_query = sys.argv[1]

    sql_output = execute_sql(sql_query=sql_query)
    print(sql_output)