# Secrets shared from banenor 917 082 308 

# Shared to Entur
resource "vault_kv_secret_v2" "secret_1" {
  mount               = "secret"

  name = "0192:917082308/entur:skyss.1/0192:917422575"
  data_json = jsonencode(
  {
    user = "secret_entur_username",
    pass = "an_encrypted_password_shared_with_entur"
  }
  )
}

# Shared to Avinor
resource "vault_kv_secret_v2" "secret_2" {
  mount               = "secret"

  name = "0192:917082308/entur:skyss.1/0192:985198292"
  data_json = jsonencode(
  {
    user = "secret_avinor_username",
    pass = "an_encrypted_password_shared_with_avinor"
  }
  )
}

# Different scope shared with entur
resource "vault_kv_secret_v2" "secret_3" {
  mount               = "secret"

  name = "0192:917082308/banenor:annetscope/0192:917422575"
  data_json = jsonencode(
  {
    user = "different_entur_username",
    pass = "another_secret_password"
  }
  )
}
