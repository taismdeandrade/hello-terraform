import pytest
import os 
import uuid
from unittest.mock import patch, MagicMock

os.environ["NOME_TABELA"] = "test_table"

@pytest.fixture(autouse=True)
def mock_dynamodb_table(): 
    with patch("lambdas.get_items.get_items.table") as mock_table:
        yield mock_table

@pytest.fixture
def sample_item():
    return [{"pk": "LIST#2025-12-12", "sk": f"ITEM#{uuid.uuid4()}", "nome": "buy milk", "status": "todo"}]

