resource "aws_lambda_function" "this" {
  function_name = var.function_name
  runtime       = var.runtime
  handler       = var.handler
  filename      = var.filename
  source_code_hash = filebase64sha256(var.filename)
  role          = var.role_arn
  timeout       = 10
}