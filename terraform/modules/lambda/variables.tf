variable "function_name" {
  description = "Nome da função Lambda"
  type        = string
}

variable "runtime" {
  description = "Runtime da função Lambda"
  type        = string
}

variable "handler" {
  description = "Handler da função Lambda"
  type        = string
}

variable "filename" {
  description = "Caminho para o arquivo ZIP/JAR da função Lambda"
  type        = string
}

variable "role_arn" {
  description = "ARN da IAM Role para a função Lambda"
  type        = string
}

variable "environment_variables" {
  description = "Variáveis de ambiente para a função Lambda"
  type        = map(string)
  default     = {}
}
