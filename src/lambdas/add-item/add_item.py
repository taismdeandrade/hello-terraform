import json
import os
import boto3
import uuid

dynamodb = boto3.resource("dynamodb")
nome_tabela = os.environ.get("NOME_TABELA")
tabela = dynamodb.Table(nome_tabela)


def add_item_handler(event, context):
    try:
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
        name = event.get("nome")
        date = event.get("data")

        tabela.put_item(
            Item={
                "PK": f"LIST#{date}",
                "SK": f"ITEM#{item_id}",
                "data": date,
                "nome": name,
                "status": "todo",
            }
        )

        return {
            "statusCode": 201,
            "body": json.dumps(
                {
                    "mensagem": "Item adicionado com sucesso",
                    "nome": name,
                    "data": date,
                    "status": "todo",
                }
            ),
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"mensagem": "Erro ao adicionar item", "erro": str(e)}),
        }
