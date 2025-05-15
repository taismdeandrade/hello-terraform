import json
import os
import boto3

dynamodb = boto3.resource('dynamodb')
nome_tabela = os.environ['NOME_TABELA']
tabela = dynamodb.Table(nome_tabela)

def edit_item_handler(event, context):
    try:
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
            'nome': event['nome']                      
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'mensagem': 'Erro ao atualizar item',
                'erro': str(e)
            })
        }
