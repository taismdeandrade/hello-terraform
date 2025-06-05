import sys
import pytest
import os
import uuid
from unittest.mock import patch, MagicMock

current_dir = os.path.dirname(os.path.abspath(__file__))

src_path = os.path.abspath(os.path.join(current_dir, "..", "..")) 

if src_path not in sys.path:
    sys.path.insert(0, src_path)

os.environ["NOME_TABELA"] = "test_table"


@pytest.fixture
def user_event(sub="test-user-id"):
    return {"requestContext": {"authorizer": {"jwt": {"claims": {"sub": sub}}}}}


@pytest.fixture(autouse=True)
def mock_dynamodb_table():
    with patch("src.lambdas.get_items.get_items.table") as mock_table:
        yield mock_table


@pytest.fixture
def sample_item():
    uid = "test-user-id"
    data = "2025-12-12"
    return [
        {
            "PK": f"USER#{uid}",
            "SK": f"ITEM#{uuid.uuid4()}LIST#{data}",
            "nome": "buy milk",
            "data": "2025-12-12",
            "status": "todo",
        }
    ]
