variable "lambda_arn" {
  description = "ARN da função Lambda que o API Gateway irá invocar"
  type        = string
}

variable "lambda_arn_get" {
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

variable "get_lambda_arn" {
  description = "GET lambda arn"
  type        = string
}

variable "edit_lambda_arn" {
  description = "ARN da função Lambda de editar itens"
  type        = string
}
