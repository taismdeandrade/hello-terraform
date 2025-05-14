provider "aws" {
  region = "us-east-1"
}

module "hello_terraform_lambda" {
  source = "./modules/lambda"

  function_name = "hello-terraform-java-lambda"
  runtime       = "java21"
  handler       = "com.example.FuncaoUmHandler"
  filename      = "../lambda/funcao-um/target/funcao-um-1.0-SNAPSHOT.jar"
  role_arn      = aws_iam_role.lambda_execution_role.arn
}

module "add_item_lambda" {
  source = "./modules/lambda"

  function_name = "add_item"
  runtime       = "java21"
  handler       = "com.example.ItemHandler"
  filename      = "../lambda/add-item/target/add-item-1.0-SNAPSHOT.jar"
  role_arn      = aws_iam_role.lambda_dynamodb_role.arn
  environment_variables = {
    DYNAMODB_TABLE_NAME = aws_dynamodb_table.item_table.name
  }
}
module "edit_item_lambda" {
  source = "./modules/lambda"

  function_name = "edit_item"
  runtime       = "java21"
  handler       = "com.example.EditItemHandler"
  filename      = "../lambda/edit-item/target/edit-item-1.0-SNAPSHOT.jar"
  role_arn      = aws_iam_role.lambda_dynamodb_role.arn
  environment_variables = {
    DYNAMODB_TABLE_NAME = aws_dynamodb_table.item_table.name
  }
}


module "remove_item_lambda" {
  source = "./modules/lambda"

  function_name = "remove_item"
  runtime       = "java21"
  handler       = "com.example.DeleteItemHandler"
  filename      = "../lambda/remove-item/target/remove-item-1.0-SNAPSHOT.jar"
  role_arn      = aws_iam_role.lambda_dynamodb_role.arn
  environment_variables = {
    DYNAMODB_TABLE_NAME = aws_dynamodb_table.item_table.name
  }
}

resource "aws_dynamodb_table" "item_table" {
  name           = "item"
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