
output "user_pool_id" {
  description = "ID do User Pool Cognito"
  value       = aws_cognito_user_pool.user_pool.id
}

output "user_pool_client_id" {
  description = "ID do Client Cognito"
  value       = aws_cognito_user_pool_client.users_pool_client.id
}
