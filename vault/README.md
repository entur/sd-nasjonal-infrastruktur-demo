## Utprøving av vault med dev-server

Foutsetter at vault og terraform er installert på kommandolinja 

* Start vault med `start.sh`
* Lag et nytt maskinportentoken og lagre token til tmp_token_maskinporten.txt
	* Merk at forventet audience i tokent må gjenspeiles i `bound_audiences` i `auth.tf`
	* Dersom du har satt et eget scope i tokenet eller ikke har tilgang til `entur:skyss.1`, så erstatt `entur:skyss.1` i `secrets.tf` og eksemplene under med ditt scope.
* Sett følgende env-params 

```
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='root'
```
* Kjør opp terraform og apply endringene
```
terraform init
terraform apply
```

# Test av read-only på andres hemmeligeheter

Vi simulerer at scopet tilhører et annet orgno, her ved BaneNOR

Disse hemmeligehetene er allerede lagt inn via `secrets.tf` for demoformål

Sjekk tilgang som super-bruker
```
vault kv get -mount=secret 0192:917082308/entur:skyss.1/0192:917422575
vault kv get -mount=secret 0192:917082308/entur:skyss.1/0192:985198292 
vault kv get -mount=secret 0192:917082308/banenor:annetscope/0192:917422575
```

Sjekk tilgang som organisasjonsbruker med maskinporten
```
vault write auth/jwt/login role=organization jwt=$(cat tmp_token_maskinporten.txt) --format=json| jq -r ".auth.client_token" > tmp_client_token.txt

# skal være true, rett scope, rett org
VAULT_TOKEN=$(cat tmp_client_token.txt) vault kv get -mount=secret 0192:917082308/entur:skyss.1/0192:917422575

# deny, rett scope, feil org
VAULT_TOKEN=$(cat tmp_client_token.txt) vault kv get -mount=secret 0192:917082308/entur:skyss.1/0192:985198292

#deny
VAULT_TOKEN=$(cat tmp_client_token.txt) vault kv get -mount=secret 0192:917082308/banenor:annetscope/0192:917422575
```


# Test av lese og skriverettigheter på eget orgnr


Write secrets as Entur `917422575`

```
#expect secret v2
VAULT_TOKEN=$(cat tmp_client_token.txt) vault kv put -mount=secret 0192:917422575/entur:skyss.1/0192:917422575 password=supersecret

# read
VAULT_TOKEN=$(cat tmp_client_token.txt) vault kv get -mount=secret 0192:917422575/entur:skyss.1/0192:917422575

# overwrite 
VAULT_TOKEN=$(cat tmp_client_token.txt) vault kv put -mount=secret 0192:917422575/entur:skyss.1/0192:917422575 password=rotatedsecret

#expect deny
VAULT_TOKEN=$(cat tmp_client_token.txt) vault kv put -mount=secret 0192:985198292/avinor:passasjere.1/0192:917422575 password=notmysecrettoshare

```