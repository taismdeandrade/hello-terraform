import json
import pytest
from unittest.mock import patch

from src.lambdas.edit_item.edit_item import edit_item_handler

@pytest.fixture(autouse=True)
def mock_dynamodb_table():
    with patch("src.lambdas.edit_item.edit_item.table") as mock_table:
        yield mock_table

def test_edit_item_success(mock_dynamodb_table):
    """
    Testa a atualização bem-sucedida de um item existente usando GSI.
    """
    mock_dynamodb_table.query.return_value = {
        'Items': [{
            'PK': 'USER#test-user',
            'SK': 'ITEM#123',
            'nome': 'item antigo',
            'status': 'todo'
        }]
    }
    mock_dynamodb_table.update_item.return_value = {}

    event = {
        'pathParameters': {
            'id_item': 'ITEM#123'
        },
        'body': json.dumps({
            'nome': 'novo nome do item',
            'status': 'done'
        })
    }
    context = {}

    response = edit_item_handler(event, context)

    assert response['statusCode'] == 200
    assert json.loads(response['body'])['mensagem'] == 'Item atualizado com sucesso'
    mock_dynamodb_table.query.assert_called_once()
    mock_dynamodb_table.update_item.assert_called_once_with(
        Key={
            'PK': 'USER#test-user',
            'SK': 'ITEM#123'
        },
        UpdateExpression='SET nome = :nome, #st = :status',
        ExpressionAttributeValues={
            ':nome': 'novo nome do item',
            ':status': 'done'
        },
        ExpressionAttributeNames={
            '#st': 'status'
        }
    )

def test_edit_item_invalid_status(mock_dynamodb_table):
    """
    Testa a validação de status inválido.
    """
    event = {
        'pathParameters': {
            'id_item': 'ITEM#123'
        },
        'body': json.dumps({
            'nome': 'item qualquer',
            'status': 'invalid'
        })
    }
    context = {}

    response = edit_item_handler(event, context)

    assert response['statusCode'] == 400
    assert json.loads(response['body'])['mensagem'] == 'O status deve ser "todo" ou "done"'
    mock_dynamodb_table.query.assert_not_called()
    mock_dynamodb_table.update_item.assert_not_called()

def test_edit_item_not_found(mock_dynamodb_table):
    """
    Testa o cenário em que o item não é encontrado via GSI.
    """
    mock_dynamodb_table.query.return_value = {
        'Items': []
    }

    event = {
        'pathParameters': {
            'id_item': 'ITEM#123'
        },
        'body': json.dumps({
            'nome': 'novo nome',
            'status': 'todo'
        })
    }
    context = {}

    response = edit_item_handler(event, context)

    assert response['statusCode'] == 404
    assert json.loads(response['body'])['mensagem'] == 'Item não encontrado'
    mock_dynamodb_table.query.assert_called_once()
    mock_dynamodb_table.update_item.assert_not_called()

def test_edit_item_general_exception(mock_dynamodb_table):
    """
    Testa o tratamento de exceções inesperadas.
    """
    mock_dynamodb_table.query.side_effect = Exception("Erro de teste")

    event = {
        'pathParameters': {
            'id_item': 'ITEM#123'
        },
        'body': json.dumps({
            'nome': 'algum nome',
            'status': 'done'
        })
    }
    context = {}

    response = edit_item_handler(event, context)

    assert response['statusCode'] == 500
    body = json.loads(response['body'])
    assert body['mensagem'] == 'Erro inesperado'
    assert 'erro' in body
    mock_dynamodb_table.query.assert_called_once()
    mock_dynamodb_table.update_item.assert_not_called()

def test_edit_item_missing_path_or_body(mock_dynamodb_table):
    """
    Testa o cenário em que id_item ou body está faltando.
    """
    event = {
        'pathParameters': {},
        'body': None
    }
    context = {}

    response = edit_item_handler(event, context)

    assert response['statusCode'] == 400
    assert json.loads(response['body'])['mensagem'] == 'Parâmetro id_item é obrigatório na URL'
    mock_dynamodb_table.query.assert_not_called()
    mock_dynamodb_table.update_item.assert_not_called()
