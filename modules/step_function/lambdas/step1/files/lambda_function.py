import json
import boto3
import botocore
import urllib.parse
import os 
from datetime import datetime

def putSNSMessage(client,arn,subject,message):
    try:
        thisResponse = client.publish(
            TopicArn = arn,   
            Message = message,   
            Subject = subject
        )
    except botocore.exceptions.ClientError as err:
        if err.response['Error']['Code'] == 'InternalError': # Generic error
            # We grab the message, request ID, and HTTP code to give to customer support
            print('Error Message: {}'.format(err.response['Error']['Message']))
            print('Request ID: {}'.format(err.response['ResponseMetadata']['RequestId']))
            print('Http code: {}'.format(err.response['ResponseMetadata']['HTTPStatusCode']))
        else:
            raise err
    return True    
    
def lambda_handler(event, context):
    print(event)
    ## Get various information from step function that called this lambda
    ## The APIGatewayEndpoint is part of the payload that is explictely declared
    ## Input is part of the initial payload that gets injected into Step Funtion
    ## Everything else is basically metadata 
    epoch:float = datetime.now().timestamp()
    executionContext:dict = event["ExecutionContext"]
    executionName:str = executionContext["Execution"]["Name"]
    inputpayload:dict = executionContext["Execution"]["Input"]
    username:str = inputpayload.get('username','unknown')
    groupname:str = inputpayload.get('groupname','unknown')

    ## bail if we don't have username or groupname
    if username == 'unknown' or groupname == 'unknown':
        return {
            'statusCode': 400,
            'OutputPayLoad': inputpayload
        }

    requestTimeStamp:str = inputpayload.get('requested',str(round(epoch)))
    statemachineName:str = executionContext["StateMachine"]["Name"]
    taskToken:str = executionContext["Task"]["Token"]
    apigwEndpint:str = event["APIGatewayEndpoint"]
    
    approveEndpoint:str = apigwEndpint + "/execution?action=approve&ex=" + executionName + "&sm=" + statemachineName + "&un=" + urllib.parse.quote_plus(username) + "&gn=" + urllib.parse.quote_plus(groupname) + "&rts=" + requestTimeStamp + "&taskToken=" + urllib.parse.quote_plus(taskToken)
    rejectEndpoint:str = apigwEndpint + "/execution?action=reject&ex=" + executionName + "&sm=" + statemachineName + "&un=" + urllib.parse.quote_plus(username) + "&gn=" + urllib.parse.quote_plus(groupname) + "&rts=" + requestTimeStamp + "&taskToken=" + urllib.parse.quote_plus(taskToken)
    
    snsClient:object = boto3.client('sns')
    sns_topic:str = os.environ["approver_sns_topic"]
    
    snsMessage:str = "\r\n\n".join(
        [
            'Welcome!',
            'This is an email requiring an approval for a step functions execution.',
            'Please check the following information and click "Approve" link if you want to approve.',
            'Execution Name -> ' + executionName,
            'Input -> ' +  json.dumps(inputpayload),
            'Approve ' + approveEndpoint,
            'Reject ' + rejectEndpoint,
            'Thanks for using Step functions!'
        ]
    )       
    
    putSNSMessage(snsClient,sns_topic,'Step Approval',snsMessage)
    return {
        'statusCode': 200,
        'OutputPayLoad': inputpayload
    }
