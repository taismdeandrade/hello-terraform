import json
import os
import boto3
import uuid

dynamodb = boto3.resource("dynamodb")
nome_tabela = os.environ.get("NOME_TABELA")
tabela = dynamodb.Table(nome_tabela)


def add_item_handler(event, context):
    try:

        user_id = event["requestContext"]["authorizer"]["jwt"]["claims"]["sub"]

        if not event.get("data") or not event.get("nome"):
            return {
                "statusCode": 400,
                "body": json.dumps(
                    {
                        "mensagem": "Erro ao adicionar item",
                        "erro": "Data e nome são obrigatórios",
                    }
                ),
            }

        item_id = str(uuid.uuid4())

        tabela.put_item(
            Item={
                "PK": f"USER#{user_id}",
                "SK": "ITEM#" + item_id,
                "data": event.get("data"),
                "nome": event.get("nome"),
                "status": "todo",
            }
        )

        return {
            "statusCode": 201,
            "body": json.dumps(
                {
                    "mensagem": "Item adicionado com sucesso",
                    "nome": event.get("nome"),
                    "data": event.get("data"),
                    "status": event.get("status"),
                }
            ),
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"mensagem": "Erro ao adicionar item", "erro": str(e)}),
        }
