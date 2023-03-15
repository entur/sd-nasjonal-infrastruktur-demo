#--------------------------------
# Enable jwt auth method
#--------------------------------


resource "vault_jwt_auth_backend" "maskinporten" {
    description         = "Maskinporten auth"
    path                = "jwt"
    jwks_url            = "https://test.maskinporten.no/jwk"
    bound_issuer        = "https://test.maskinporten.no/"
}


output "mount_name" {
  value = vault_jwt_auth_backend.maskinporten.accessor
}

resource "vault_jwt_auth_backend_role" "maskinporten" {
  backend         = vault_jwt_auth_backend.maskinporten.path
  role_name       = "organization"
  token_policies  = ["producer", "consumer"]

  bound_audiences = ["https://hoc-cluster-public-vault-e58f231b.dada9b17.z1.hashicorp.cloud"]
  user_claim      = "/consumer/ID"
  user_claim_json_pointer = true
  claim_mappings = {
    "scope": "maskinportenscope"
  }
  role_type       = "jwt"
}

