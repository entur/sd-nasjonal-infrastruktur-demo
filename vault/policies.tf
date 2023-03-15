#---------------------
# Create policies
#---------------------



resource "vault_policy" "consumer_policy" {
  name   = "consumer"
  policy = templatefile("policies/consumer-policy.tftpl", {mount_name = vault_jwt_auth_backend.maskinporten.accessor})
}

resource "vault_policy" "producer_policy" {
  name   = "producer"
  policy = templatefile("policies/producer-policy.tftpl", {mount_name = vault_jwt_auth_backend.maskinporten.accessor})
}

