import json
import os
import boto3

dynamodb = boto3.resource('dynamodb')
nome_tabela = os.environ.get('NOME_TABELA')
tabela = dynamodb.Table(nome_tabela)

def edit_item_handler(event, context):
    try:
        status = event.get('status')
        if status not in ["todo", "done"]:
            return {
                'statusCode': 400,
                'body': json.dumps({'mensagem': 'O status deve ser "todo" ou "done"'})
            }
        
        response = tabela.get_item(
            Key={
                'SK': event['sk'],
                'PK': event['pk']
            }
        )
        if 'Item' not in response:
            return {
                'statusCode': 404,
                'body': json.dumps({'mensagem': 'Item não encontrado'})
            }
        
        tabela.update_item(
            Key={
                'SK': event['sk'],
                'PK': event['pk']
            },
            UpdateExpression='SET nome = :nome, #st = :status',
            ExpressionAttributeValues={
                ':nome': event['nome'],
                ':status': event['status']
            },
            ExpressionAttributeNames={
                '#st': 'status' 
            }
        )
        return {
            'mensagem': 'Item atualizado com sucesso',
            'status': event.get('status'),
            'nome': event.get('nome')
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'mensagem': 'Erro inesperado', 'erro': str(e)})
        }

