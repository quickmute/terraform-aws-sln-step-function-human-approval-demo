import boto3
import botocore
import json
import os
import base64
import time

def lambda_handler(event, context):
    print(event)
    stepClient:object = boto3.client('stepfunctions')
    action:str = event["query"]["action"]
    taskToken:str = event["query"]["taskToken"]
    statemachineName:str = event["query"]["sm"]
    executionName:str = event["query"]["ex"]
    username:str = event["query"]["un"]
    groupname:str = event["query"]["gn"]
    requestTimeStamp:str = event["query"]["rts"]

    ## this is the URL that the approver will be redirected to
    return_url:str = os.environ["return_url"]
    
    ## Create message dict
    ## Default to rejection!
    message:dict = {
        "ExecutionName": executionName,
        "StateMachineName": statemachineName,
        "Action" : action,
        "UserName" : username,
        "GroupName" : groupname,
        "RequestedTimeStamp" : requestTimeStamp,
        "Status" : "Rejected!"
    }

    print("Action:",action)
    if action == "approve":
        print("Approve")
        message["Status"] = "Approved!" 
    else:
        print("Rejected")
        message["Status"] = "Rejected!" 
    
    ## need try-catch here
    task_response = stepClient.send_task_success(
        taskToken=taskToken,
        output=json.dumps(message)
    )
    print("Task Response:",task_response)
    ## 
    
    ## Send redirect response back
    response = {
        "headers": {"Location": return_url, },
        "statusCode": 302,
    }
    return response