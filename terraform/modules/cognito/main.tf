resource "aws_cognito_user_pool" "user_pool" {
  name = "users"

  password_policy {
    minimum_length    = 8
    require_uppercase = true
    require_numbers   = true
    require_symbols   = true
  }

  schema {
    name                = "email"
    required            = true
    mutable             = false
    attribute_data_type = "String"
  }

  schema {
    name                = "name"
    required            = false
    mutable             = true
    attribute_data_type = "String"
  }

  alias_attributes = ["email"]
  auto_verified_attributes = ["email"]
  
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

}

resource "aws_cognito_user_pool_client" "users_pool_client" {
  name         = "users_pool_client"
  user_pool_id = aws_cognito_user_pool.user_pool.id
  refresh_token_validity = 90

  allowed_oauth_flows_user_pool_client = true
  prevent_user_existence_errors = "ENABLED"
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]

  allowed_oauth_flows = ["code", "implicit"] 
   allowed_oauth_scopes = ["email", "openid", "profile"] 
  
   callback_urls = ["http://localhost:8080/callback"]

}
