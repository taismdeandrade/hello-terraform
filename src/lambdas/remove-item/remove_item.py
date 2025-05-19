import json
import os
import boto3

dynamodb = boto3.resource('dynamodb')
nome_tabela = os.environ['NOME_TABELA']
tabela = dynamodb.Table(nome_tabela)

def remove_item_handler(event, context):
    try:
        if 'pk' not in event or 'sk' not in event:
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'message': 'PK e SK são obrigatórios para remover o item'
                })
            }
        
        tabela.delete_item(Key={
            'SK': event['sk'],
            'PK': event['pk'],
               
        })
        return {
            'mensagem': 'Item removido com sucesso',   
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Erro ao remover o item',
                'error': str(e)
            })
        }