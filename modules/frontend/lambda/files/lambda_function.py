import boto3
import botocore
import json
import os
from datetime import datetime


def putDynamoItem(client, arn, pk, sk, comment):
    try:
        client.put_item(
            TableName=arn,
            Item={"PK": {"S": pk}, "SK": {"S": sk}, "Status": {"S": comment}},
        )
    except botocore.exceptions.ClientError as err:
        # update this to handle the error more gently
        raise err
    return True


def startStepExecution(client, arn, input):
    try:
        output = client.start_execution(stateMachineArn=arn, input=input)
    except botocore.exceptions.ClientError as err:
        # update this to handle the error more gently
        # If we hit SFN.Client.exceptions.ExecutionLimitExceeded then we need to back off and try again
        raise err
    return output["executionArn"]


def lambda_handler(event, context):
    print(event)
    ## get content from env variable
    referer_address: str = os.environ["referer_address"]
    referer_host: str = os.environ["referer_host"]
    stepFunction_arn: str = os.environ["stepFunction_arn"]
    log_dynamodb_arn: str = os.environ["log_dynamodb_arn"]
    ## get payload stuff
    payload_body: dict = json.loads(event.get("body", "{}"))
    header_referer_address: str = event["headers"].get("Referer", "NA")
    header_referer_host: str = event["headers"].get("Host", "NA")
    header_source_ip: str = event["headers"].get("X-Forwarded-For", "NA")
    print("Source", header_source_ip)
    print("Host", header_referer_host)
    print("Referer", header_referer_address)

    ## validation, if this isn't coming from where we are expecting the bail
    if referer_address not in header_referer_address:
        return {
            "statusCode": 400,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": {"Response": "Unknown Referer"},
        }
    if referer_host not in header_referer_host:
        return {
            "statusCode": 400,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": {"Response": "Unknown Host"},
        }
    # Print payload of body
    for key, value in payload_body.items():
        print(f"{key}: {value}")

    # Let's assume our partition key will be a combination of 2 fields
    # if field names in index.html changes then we need to update it here too
    field1: str = payload_body.get("field1", "unknown")
    field2: str = payload_body.get("field2", "unknown")
    if field1 == "unknown" or field2 == "unknown":
        return {
            "statusCode": 400,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": {"Response": "Field not found"},
        }

    pk: str = "{0}-{1}".format(field1, field2)
    ## Get current epoch Timestamp
    # and our Sort key will be the epoch time
    sk: str = str(round(datetime.now().timestamp()))
    # Print these values for log
    print("pk:", pk)
    print("sk:", sk)

    # write this to dynamodb
    dynamodb: object = boto3.client("dynamodb")
    putDynamoItem(dynamodb, log_dynamodb_arn, pk, sk, "User Submitted Request")
    # send this to step function
    stepClient: object = boto3.client("stepfunctions")
    stepInput: str = json.dumps(
        {
            "groupname": field1,
            "username": field2,
            "requested": str(round(datetime.now().timestamp())),
        }
    )
    stepResponse: str = startStepExecution(stepClient, stepFunction_arn, stepInput)
    # return pk to the requester
    result = {"Response": stepResponse}

    return {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps(result),
    }
