resource "aws_apigatewayv2_api" "http_api" {
  name          = "http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_authorizer" "cognito" {
  name             = "cognito-authorizer"
  api_id           = aws_apigatewayv2_api.http_api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  jwt_configuration {
    audience = [var.cognito_client_id]
    issuer   = "https://cognito-idp.${var.region}.amazonaws.com/${var.user_pool_id}"
  }
}

resource "aws_apigatewayv2_integration" "list_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.get_lambda_arn}/invocations"
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_lambda_permission" "allow_apigw_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_list_invoke" {
  statement_id  = "AllowExecutionFromAPIGatewayList"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_arn_get
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}


resource "aws_apigatewayv2_route" "hello" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /hello"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id

  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "list" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /list-items"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id

  target = "integrations/${aws_apigatewayv2_integration.list_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

output "api_endpoint" {
  description = "Endpoint base do API Gateway"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "api_execution_arn" {
  description = "The execution ARN of the API Gateway"
  value       = aws_apigatewayv2_api.http_api.execution_arn
}

