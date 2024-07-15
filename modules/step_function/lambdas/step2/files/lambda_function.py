import json
from datetime import datetime

def lambda_handler(event, context):
    print(event)
    action:str = event["Action"]
    userName:str = event["UserName"] 
    groupName:str = event["GroupName"] 
    status:str = event["Status"] 
    executionName:str = event["ExecutionName"] 
    statemachineName:str = event["StateMachineName"]
    requestTimeStamp:str = event["RequestedTimeStamp"]
    
    ## build the payload for next step
    ## Update the sk with the new timestamp
    inputpayload = {
        "pk":f"{groupName}-{userName}",
        "sk":str(round(datetime.now().timestamp())),
        "status":action
    }
    return {
        'statusCode': 200,
        'OutputPayLoad': inputpayload
    }
