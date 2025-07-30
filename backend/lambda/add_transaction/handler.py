import json
import boto3
import os
from datetime import datetime

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ.get("TABLE_NAME", "Transactions"))

def lambda_handler(event, context):
    body = json.loads(event.get("body", "{}"))
    
    transaction = {
        "id": str(datetime.utcnow().timestamp()),   # simple unique ID
        "amount": body.get("amount"),
        "category": body.get("category", "Uncategorized"),
        "timestamp": datetime.utcnow().isoformat()
    }

    table.put_item(Item=transaction)

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Transaction added", "transaction": transaction}),
    }
