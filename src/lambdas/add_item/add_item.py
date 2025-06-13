import json
import os
import boto3
import uuid

dinamodb = boto3.resource("dynamodb")
nome_tabela = os.environ.get("NOME_TABELA")
tabela = dinamodb.Table(nome_tabela)


def add_item_handler(event, context):
    try:
        user_id = event["requestContext"]["authorizer"]["jwt"]["claims"]["sub"]
    except KeyError:
        return {
            "statusCode": 401,
            "body": json.dumps({"error": f"Usuário não autenticado"}),
        }
    try:
        json_recebido = event.get("body", "{}")
        request_body = json.loads(json_recebido)

        data = request_body.get("data")
        nome = request_body.get("nome")

        if not data or not nome:
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
                "SK": f"ITEM#{item_id}LIST#{data}",
                "Nome": nome,
                "Data": data,
                "Status": "todo",
            }
        )

        return {
            "statusCode": 201,
            "body": json.dumps(
                {
                    "mensagem": "Item adicionado com sucesso",
                    "Nome": nome,
                    "Data": data,
                    "Status": "todo",
                }
            ),
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"mensagem": "Erro ao adicionar item", "erro": str(e)}),
        }
