import json
import os
import boto3
import uuid

dynamodb = boto3.resource('dynamodb')
nome_tabela = os.environ['NOME_TABELA']
tabela = dynamodb.Table(nome_tabela)

def add_item_handler(event, context):
    try:
        tabela.put_item(Item={
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