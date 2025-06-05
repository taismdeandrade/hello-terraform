import json
import os
import boto3
from boto3.dynamodb.conditions import Key

DYNAMODB = boto3.resource("dynamodb")
nome_tabela = os.environ.get("NOME_TABELA")
TABELA = DYNAMODB.Table(nome_tabela)

def edit_item_handler(event, context):
    try:
        user_id = event["requestContext"]["authorizer"]["claims"]["sub"]
    except KeyError:
        return {
            "statusCode": 401,
            "body": json.dumps({"error": "Usuário não autenticado"}),
    }
    try:
        path_parameters = event.get('pathParameters', {})
        id_item = path_parameters.get('id_item')

        if not id_item:
            return {
                'statusCode': 400,
                'body': json.dumps({'mensagem': 'Parâmetro id_item é obrigatório na URL'})
            }

        body = json.loads(event.get('body', '{}'))
        novo_nome = body.get('nome')
        novo_status = body.get('status')

        if novo_status not in ["todo", "done"]:
            return {
                'statusCode': 400,
                'body': json.dumps({'mensagem': 'O status deve ser "todo" ou "done"'})
            }

        # Consulta usando GSI "SK-index"
        response = TABELA.query(
            IndexName='SK-index',
            KeyConditionExpression=Key('SK').eq(id_item)
        )
        items = response.get('Items', [])
        if not items:
            return {
                'statusCode': 404,
                'body': json.dumps({'mensagem': 'Item não encontrado'})
            }

        item = items[0]
        pk = item['PK']

        TABELA.update_item(
            Key={
                'PK': pk,
                'SK': id_item
            },
            UpdateExpression='SET nome = :nome, #st = :status',
            ExpressionAttributeValues={
                ':nome': novo_nome,
                ':status': novo_status
            },
            ExpressionAttributeNames={
                '#st': 'status'
            }
        )

        return {
            'statusCode': 200,
            'body': json.dumps({'mensagem': 'Item atualizado com sucesso'})
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'mensagem': 'Erro inesperado', 'erro': str(e)})
        }
