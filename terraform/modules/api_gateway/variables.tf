variable "lambda_arn" {
  description = "ARN da função Lambda que o API Gateway irá invocar"
  type        = string
}

variable "user_pool_id" {
  description = "ID do Cognito User Pool"
  type        = string
}

variable "region" {
  description = "Região da AWS onde o Cognito está"
  type        = string
}

variable "cognito_client_id" {
  description = "ID do App Client no Cognito"
  type        = string
}
