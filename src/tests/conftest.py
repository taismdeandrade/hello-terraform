import pytest
import os
import uuid
from unittest.mock import patch, MagicMock

os.environ["NOME_TABELA"] = "test_table"


@pytest.fixture
def user_event(sub="test-user-id"):
    return {"requestContext": {"authorizer": {"jwt": {"claims": {"sub": sub}}}}}


@pytest.fixture(autouse=True)
def mock_dynamodb_table():
    with patch("lambdas.get_items.get_items.table") as mock_table:
        yield mock_table


@pytest.fixture
def sample_item():
    uid = "test-user-id"
    return [
        {
            "PK": f"USER#{uid}",
            "SK": f"ITEM#{uuid.uuid4()}",
            "nome": "buy milk",
            "data": "2025-12-12",
            "status": "todo",
        }
    ]
