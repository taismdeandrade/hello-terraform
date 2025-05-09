
resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  runtime          = var.runtime
  handler          = var.handler
  filename         = var.filename
  source_code_hash = filebase64sha256(var.filename)
  role             = var.role_arn
  timeout          = 10

  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }
}

output "function_arn" {
  description = "ARN da função Lambda"
  value       = aws_lambda_function.this.arn
}

output "function_name" {
  description = "Nome da função Lambda"
  value       = aws_lambda_function.this.function_name
}

output "invoke_arn" {
  description = "ARN de invocação da função Lambda"
  value       = aws_lambda_function.this.invoke_arn
}