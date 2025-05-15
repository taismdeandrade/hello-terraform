provider "aws" {
  region = "us-east-1"
}

resource "aws_dynamodb_table" "item_table" {
  name           = "itens"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "PK"
  range_key      = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }
}

data "archive_file" "add_zip" {
  type        = "zip"
  source_dir  = "../src/lambdas/add-item/"
  output_path = "../src/lambdas/add-item/add_item.zip"
}

data "archive_file" "edit_zip" {
  type        = "zip"
  source_dir  = "../src/lambdas/edit-item/"
  output_path = "../src/lambdas/edit-item/edit_item.zip"
}

resource "aws_lambda_function" "add_item" {
  filename         = data.archive_file.add_zip.output_path
  function_name    = "add_item"
  role             = aws_iam_role.lambda_dynamodb_role.arn
  handler          = "add_item.add_item_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.add_zip.output_base64sha256
  timeout          = 15

    environment {
    variables = {
      NOME_TABELA = "itens"
    }
  }
}


resource "aws_lambda_function" "edit_item" {
  filename         = data.archive_file.edit_zip.output_path
  function_name    = "edit_item"
  role             = aws_iam_role.lambda_dynamodb_role.arn
  handler          = "edit_item.edit_item_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.edit_zip.output_base64sha256
  timeout          = 15

    environment {
    variables = {
      NOME_TABELA = "itens"
    }
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "hello-terraform-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "lambda_dynamodb_role" {
  name = "lambda-dynamodb-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "lambda_execution_policy" {
  name        = "hello-terraform-policy"
  description = "Permissões básicas para execução da Lambda (Java)"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "lambda-dynamodb-policy"
  description = "Permite à Lambda realizar operações CRUD na tabela DynamoDB"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ],
        Effect   = "Allow",
        Resource = aws_dynamodb_table.item_table.arn
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_attachment" {
  role       = aws_iam_role.lambda_dynamodb_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}