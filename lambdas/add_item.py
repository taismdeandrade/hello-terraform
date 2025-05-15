import json
import boto3
import uuid

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('itens')

def lambda_handler(event, context):
    try:
        table.put_item(Item={
            'SK': 'ITEM#' + str(uuid.uuid4()),
            'PK': 'LIST#' + event['data'],
            'nome': event['nome'],
            'status': 'todo'            
        })
        return {
            'mensagem': 'Item adicionado com sucesso',
            'data': event['data'],
            'nome': event['nome']                      
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Erro ao adicionar item',
                'error': str(e)
            })
        }