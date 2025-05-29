import json
import pytest
from unittest.mock import patch, MagicMock

from src.lambdas.edit_item.edit_item import edit_item_handler

@pytest.fixture(autouse=True)
def mock_dynamodb_table():
    with patch("src.lambdas.edit_item.edit_item.table") as mock_table:
        yield mock_table

def test_edit_item_success(mock_dynamodb_table):
    """
    Testa a atualização bem-sucedida de um item existente.
    """
    mock_dynamodb_table.get_item.return_value = {
        'Item': {
            'PK': 'USER#test-user',
            'SK': 'ITEM#123',
            'nome': 'item antigo',
            'status': 'todo'
        }
    }
    mock_dynamodb_table.update_item.return_value = {}

    event = {
        'pk': 'USER#test-user',
        'sk': 'ITEM#123',
        'nome': 'novo nome do item',
        'status': 'done'
    }
    context = {}

    response = edit_item_handler(event, context)

    assert response == {
        'mensagem': 'Item atualizado com sucesso',
        'status': 'done',
        'nome': 'novo nome do item'
    }
    mock_dynamodb_table.get_item.assert_called_once_with(
        Key={
            'SK': 'ITEM#123',
            'PK': 'USER#test-user'
        }
    )
    mock_dynamodb_table.update_item.assert_called_once_with(
        Key={
            'SK': 'ITEM#123',
            'PK': 'USER#test-user'
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
        'pk': 'USER#test-user',
        'sk': 'ITEM#123',
        'nome': 'item qualquer',
        'status': 'invalid_status'
    }
    context = {}

    response = edit_item_handler(event, context)

    assert response == {
        'statusCode': 400,
        'body': json.dumps({'mensagem': 'O status deve ser "todo" ou "done"'})
    }
    mock_dynamodb_table.get_item.assert_not_called()
    mock_dynamodb_table.update_item.assert_not_called()

def test_edit_item_not_found(mock_dynamodb_table):
    """
    Testa o cenário em que o item não é encontrado.
    """
    mock_dynamodb_table.get_item.return_value = {}
    mock_dynamodb_table.update_item.return_value = {}

    event = {
        'pk': 'USER#test-user',
        'sk': 'ITEM#123',
        'nome': 'novo nome',
        'status': 'todo'
    }
    context = {}

    response = edit_item_handler(event, context)

    assert response == {
        'statusCode': 404,
        'body': json.dumps({'mensagem': 'Item não encontrado'})
    }
    mock_dynamodb_table.get_item.assert_called_once_with(
        Key={
            'SK': 'ITEM#123',
            'PK': 'USER#test-user'
        }
    )
    mock_dynamodb_table.update_item.assert_not_called()

def test_edit_item_general_exception(mock_dynamodb_table):
    """
    Testa o tratamento de exceções inesperadas.
    """
    mock_dynamodb_table.get_item.side_effect = Exception("Erro de teste")

    event = {
        'pk': 'USER#test-user',
        'sk': 'ITEM#123',
        'nome': 'novo nome',
        'status': 'done'
    }
    context = {}

    response = edit_item_handler(event, context)

    assert response['statusCode'] == 500
    assert json.loads(response['body'])['mensagem'] == 'Erro inesperado'
    assert 'erro' in json.loads(response['body'])
    mock_dynamodb_table.get_item.assert_called_once()
    mock_dynamodb_table.update_item.assert_not_called()

def test_edit_item_missing_keys(mock_dynamodb_table):
    """
    Testa o cenário em que as chaves PK ou SK estão faltando no evento.
    """
    event = {
        'nome': 'algum nome',
        'status': 'todo'
    }
    context = {}

    response = edit_item_handler(event, context)

    assert response['statusCode'] == 500
    assert json.loads(response['body'])['mensagem'] == 'Erro inesperado'
    assert 'erro' in json.loads(response['body'])
    mock_dynamodb_table.get_item.assert_not_called()
    mock_dynamodb_table.update_item.assert_not_called()