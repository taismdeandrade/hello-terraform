output "api_endpoint" {
  description = "Endpoint base do API Gateway"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "api_execution_arn" {
  description = "The execution ARN of the API Gateway"
  value       = aws_apigatewayv2_api.http_api.execution_arn
}

