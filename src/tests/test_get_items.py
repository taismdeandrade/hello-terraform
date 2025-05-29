import json
from src.lambdas.get_items.get_items import get_items_handler


def test_get_items_success(mock_dynamodb_table, sample_item, user_event):

    expected_items = sample_item
    mock_dynamodb_table.query.return_value = {"Items": expected_items}

    response = get_items_handler(user_event, {})

    assert response["statusCode"] == 200
    assert json.loads(response["body"]) == expected_items


def test_get_items_empty_table(mock_dynamodb_table, user_event):

    mock_dynamodb_table.query.return_value = {"Items": []}

    response = get_items_handler(user_event, {})

    assert response["statusCode"] == 200
    assert json.loads(response["body"]) == []


def test_get_items_failure(mock_dynamodb_table, user_event):

    mock_dynamodb_table.query.side_effect = Exception("simulated error")

    response = get_items_handler(user_event, {})

    assert response["statusCode"] == 500
    assert "simulated error" in json.loads(response["body"])["error"]
