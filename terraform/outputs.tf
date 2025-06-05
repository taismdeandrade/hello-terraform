output "cognito_user_pool_id" {
  value = module.cognito.user_pool_id
}
output "cognito_client_id" {
  value = module.cognito.user_pool_client_id
}
output "api_endpoint" {
  value = module.api.api_endpoint
}
