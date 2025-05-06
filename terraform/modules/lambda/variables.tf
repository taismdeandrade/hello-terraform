variable "function_name" {
  type = string
  default = "hello-terraform-java-lambda"
  description = "O nome da função Lambda."
}

variable "runtime" {
  type = string
  default = "java21" 
  description = "O runtime da função Lambda."
}

variable "handler" {
  type = string
  description = "O handler da função Lambda (ex: com.example.HelloTerraformHandler::handleRequest)."
}

variable "filename" {
  type = string
  description = "O caminho para o arquivo .jar da Lambda."
}

variable "role_arn" {
  type = string
  description = "O ARN da role de execução da Lambda."
}