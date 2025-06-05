import json
import os
import boto3
from boto3.dynamodb.conditions import Key

DYNAMODB = boto3.resource("dynamodb")
nome_tabela = os.environ.get("NOME_TABELA")
TABELA = DYNAMODB.Table(nome_tabela)

def get_items_handler(event, context):

    try:
        user_id = event["requestContext"]["authorizer"]["jwt"]["claims"]["sub"]
    except KeyError:
        return {
            "statusCode": 401,
            "body": json.dumps({"message": "Usuário não autenticado"}),
        }

    try:
        response = TABELA.query(
            KeyConditionExpression=Key("PK").eq(f"USER#{user_id}")
            & Key("SK").begins_with("ITEM#")
        )

        items = response.get("Items", [])

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Credentials": True,
            },
            "body": json.dumps(items),
        }

    except Exception as e:
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
