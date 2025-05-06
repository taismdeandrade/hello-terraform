module "hello_terraform_lambda" {
  source = "./modules/lambda"

  function_name = "hello-terraform-java-lambda"
  runtime       = "java21"                     
  handler       = "com.example.FuncaoUmHandler"
  filename      = "../lambda/funcao-um/target/funcao-um-1.0-SNAPSHOT.jar" 
  role_arn      = aws_iam_role.lambda_execution_role.arn 
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

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
}

provider "aws" {
  region = "us-east-1" 
}