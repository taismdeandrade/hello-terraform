terraform {
  backend "s3" {
    bucket = "tais-shopping-list"
    key    = "state/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "577902954365"
}

resource "aws_dynamodb_table" "item_table" {
  name         = "itens"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PK"
  range_key    = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  global_secondary_index {
    name            = "SK-index"
    hash_key        = "SK"
    projection_type = "ALL"
  }
}

data "archive_file" "hello_zip" {
  type        = "zip"
  source_dir  = "../src/lambdas/hello-terraform/"
  output_path = "../src/lambdas/hello-terraform/hello.zip"
}

data "archive_file" "get_items_zip" {
  type        = "zip"
  source_dir  = "../src/lambdas/get_items/"
  output_path = "../src/lambdas/get_items/get_items.zip"
}

data "archive_file" "add_zip" {
  type        = "zip"
  source_dir  = "../src/lambdas/add-item/"
  output_path = "../src/lambdas/add-item/add_item.zip"
}

data "archive_file" "edit_zip" {
  type        = "zip"
  source_dir  = "../src/lambdas/edit_item/"
  output_path = "../src/lambdas/edit_item/edit_item.zip"
}

data "archive_file" "remove_zip" {
  type        = "zip"
  source_dir  = "../src/lambdas/remove-item/"
  output_path = "../src/lambdas/remove-item/remove_item.zip"
}

resource "aws_lambda_function" "hello" {
  filename         = data.archive_file.hello_zip.output_path
  function_name    = "hello"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "hello.hello_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.hello_zip.output_base64sha256
  timeout          = 15
}

resource "aws_lambda_function" "get_items" {
  filename         = data.archive_file.get_items_zip.output_path
  function_name    = "get_items"
  role             = aws_iam_role.lambda_dynamodb_role.arn
  handler          = "get_items.get_items_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.get_items_zip.output_base64sha256
  timeout          = 15

  environment {
    variables = {
      NOME_TABELA = "itens"
    }
  }
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

resource "aws_lambda_function" "remove_item" {
  filename         = data.archive_file.remove_zip.output_path
  function_name    = "remove_item"
  role             = aws_iam_role.lambda_dynamodb_role.arn
  handler          = "remove_item.remove_item_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.remove_zip.output_base64sha256
  timeout          = 15

  environment {
    variables = {
      NOME_TABELA = "itens"
    }
  }
}

resource "aws_lambda_permission" "api_gw_hello" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api.api_execution_arn}/*/*"
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
  description = "Permissões básicas para execução da Lambda"
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
        Effect = "Allow",
        Resource = [
          aws_dynamodb_table.item_table.arn,
          "${aws_dynamodb_table.item_table.arn}/index/SK-index"
        ]
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


output "cognito_user_pool_id" {
  value = module.cognito.user_pool_id
}
output "cognito_client_id" {
  value = module.cognito.user_pool_client_id
}
output "api_endpoint" {
  value = module.api.api_endpoint
}


module "cognito" {
  source = "./modules/cognito"

}
module "api" {
  source            = "./modules/api_gateway"
  lambda_arn        = aws_lambda_function.hello.arn
  get_lambda_arn    = aws_lambda_function.get_items.arn
  lambda_arn_get    = aws_lambda_function.get_items.arn
  edit_lambda_arn   = aws_lambda_function.edit_item.arn
  user_pool_id      = module.cognito.user_pool_id
  region            = var.region
  cognito_client_id = module.cognito.user_pool_client_id
}