from typing import List, Literal, Union
from pydantic import BaseModel, Field
import logging
import json

# agents
from agents.dbresearcher import dbresearcher
from agents.sqlwriter import sqlwriter
from agents.dataviz import dataviz
from agents.sqlexecutor import sqlexecutor

from evaluate.evaluators import evaluate_report
from prompty.tracer import trace, Tracer, console_tracer, PromptyTracer

types = Literal["message", "database researcher", "sql writer", "sql executor", "dataviz", "error", "partial", ]

class Message(BaseModel):
    type: types
    message: str | dict | None
    data: List | dict = Field(default={})

    def to_json_line(self):
        return self.model_dump_json().replace("\n", "") + "\n"


class Task(BaseModel):
    question: str

DEFAULT_LOG_LEVEL = 25

def log_output(*args):
    logging.log(DEFAULT_LOG_LEVEL, *args)

def send_message(message: str):
    return Message(
        type="message", message=message
    ).to_json_line()

def start_message(type: types):
    return Message(
        type="message", message=f"Starting {type} agent task..."
    ).to_json_line()

def complete_message(type: types, result):
    return Message(
        type=type, message=f"Completed {type} task", data=result
    ).to_json_line()


def error_message(error: Exception):
    return Message(
        type="error", message="An error occurred.", data={"error": str(error)}
    ).to_json_line()

def send_dbresearch(research_result):
    return json.dumps(("dbresearch", research_result))

def send_sqlwriter(sqlwriter_result):
    return json.dumps(("sqlwriter", sqlwriter_result))

def send_sqlexecutor(sqlexecutor_result):
    return json.dumps(("sqlexecutor", sqlexecutor_result))

def send_dataviz(dataviz_result):
    return json.dumps(("dataviz", dataviz_result))

def building_agents_message():
    return Message(
        type="message", message="Initializing Agent Service, please wait a few seconds..."
    ).to_json_line()

@trace
def create(question, evaluate=False):
    
    feedback = "No Feedback"

    yield building_agents_message()

    yield start_message("database researcher")
    dbresearch_result = dbresearcher.research(question, feedback)
    yield complete_message("database researcher", dbresearch_result)

    yield start_message("sql writer")
    sqlquery_result = sqlwriter.suggest_sql_query(question, dbresearch_result)
    yield complete_message("sql writer", sqlquery_result)

    yield start_message("sql executor")
    sqlexecutor_result = sqlexecutor.execute_sql(sqlquery_result["sql_query"])
    yield complete_message("sql executor", sqlexecutor_result)

    retry_count = 0
    while(str(sqlexecutor_result["status"]).lower().startswith("failed")):
        print ("retrying")
        yield send_message(f"Sending database researcher feedback ({retry_count + 1})...")
        
        # Regenerate with feedback loop
        yield start_message("database researcher")
        dbresearch_result = dbresearcher.research(question, json.dumps(sqlexecutor_result))
        yield complete_message("database researcher", dbresearch_result)

        yield start_message("sql writer")
        sqlquery_result = sqlwriter.suggest_sql_query(question, dbresearch_result)
        yield complete_message("sql writer", sqlquery_result)

        yield start_message("sql executor")
        sqlexecutor_result = sqlexecutor.execute_sql(sqlquery_result["sql_query"])
        yield complete_message("sql executor", sqlexecutor_result)

        retry_count += 1
        if retry_count >= 2:
            break
    
    if (str(sqlexecutor_result["status"]).lower().startswith("success")):
        yield start_message("dataviz")
        dataviz_result = dataviz.execute_dataviz(question, sqlexecutor_result["sql_query"], json.dumps(sqlexecutor_result["data"]))
        yield complete_message("dataviz", dataviz_result)

    #these need to be yielded for calling evals from evaluate.evaluate
    yield send_dbresearch(dbresearch_result)
    yield send_sqlwriter(sqlquery_result)
    yield send_sqlexecutor(sqlexecutor_result)

    if (str(sqlexecutor_result["status"]).lower().startswith("success")):
        yield send_dataviz(dataviz_result)

    if evaluate:
        print("Evaluating report...")
        evaluate_article_in_background(
            research_context=research_context,
            product_context=product_context,
            assignment_context=assignment_context,
            research=research_result,
            products=product_result,
            article=full_result,
        )

@trace  
def test_create_dataviz(question):
    for result in create(question):
        print (result)
        # parsed_result = json.loads(result)
        # if type(parsed_result) is dict:
        #     if parsed_result['type'] == 'researcher':
        #         print(parsed_result['data'])
        #     if parsed_result['type'] == 'marketing':
        #         print(parsed_result['data'])
        #     if parsed_result['type'] == 'editor':
        #         print(parsed_result['data'])
        # if type(parsed_result) is list:
        #     if parsed_result[0] == "writer":
        #         article = parsed_result[1]
        #         print(f'Article: {article}')
    
if __name__ == "__main__":
    local_trace = PromptyTracer()
    Tracer.add("PromptyTracer", local_trace.tracer)
    question = "Show me the latest market data from Apple ?"

    test_create_dataviz(question)
