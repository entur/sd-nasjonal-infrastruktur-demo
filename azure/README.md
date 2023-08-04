
TODO:
sky.organisasjonsnavn.no bør erstattes med ????TODO


# Bruk av Azure Service Principal med Federated Identity basert på Maskinporten
Du må ha en Azure konto, og az CLI-verktøy installert.

Login i Azure fra kommandolinjen:

```
az login
{
...
    "tenantId": "5e55abcd-dddd-4444-bbbb-4a4a4a4a4a4aa",
...
}
# Used later for logging in with Skyporten OIDC token
export AZURE_TENANT_ID="5e55abcd-dddd-4444-bbbb-4a4a4a4a4a4aa"
```

## 1. Create the Azure Active Directory application, and federated identity credentials

### Create the Azure Active Directory application
This command will output JSON with an appId that is your client-id.
The objectId is APPLICATION-OBJECT-ID and it will be used for
creating federated credentials with Graph API calls.

```
az ad app create --display-name oidcpilotapp
{
...
  "appId": "4444444-aaaa-aaaa-aaaa-121212121212",
...
}
export AD_APP_ID="4444444-aaaa-aaaa-aaaa-121212121212"
```

### Add federated credentials

#### Create credential.json

credential.json should contain this:

``````json
{
    "name": "oidcpilotcreds",
    "issuer": "https://maskinporten.dev/",
    "subject": "0192:999999999",
    "description": "Testing skyporten",
    "audiences": [
        "https://sky.organisasjonsnavn.no"
    ]
}
``````
I subject, erstatt 999999999 med konsument organisasjonen sitt organisasjonsnummer,
som er knyttet til oppsettet i samarbeidsportalen.
`subject` er det som begrenser hvilken organisasjon som skal kunne autorisere seg med
denne federated identity.


sky.organisasjonsnavn.no bør erstattes med ????TODO

Run the following command to create a new federated identity credential for your Azure Active Directory application.

```
az ad app federated-credential create --id "$AD_APP_ID" --parameters credential.json
```


## 2. Create a service principal.
This command generates JSON output with a different objectId will be used
in the next step. The new id is the service principal ID.

```
az ad sp create --id "$AD_APP_ID"
{
...
  "id": "eeeeeeee-5555-3333-2222-aaaa11112222",
...
}
export SERVICE_PRINCIPAL_ID="eeeeeeee-5555-3333-2222-aaaa11112222"
```

## 3. Create a new role assignment by subscription and object.
By default, the role assignment will be tied to your default subscription.
Replace $SUBSCRIPTION_ID with your subscription ID.

```
# Use default subscription, if desired
export SUBSCRIPTION_ID=`az account show --query id --output tsv`
```

## 4. Create a resource group if you don't want to give access to an existing one.

```
export STORAGE_RG="filestorage-rg"
az group create --name $STORAGE_RG --location northeurope
{
...
  "id": "/subscriptions/dddddddd-4444-3333-2222-aaaabbbbcccc/resourceGroups/filestorage-rg",
...
}
```

## 6. Create storage account and upload a text file there

```
# Create storage account
export STORAGE_ACC="skyportentest"
az storage account create \
  --name $STORAGE_ACC \
  --resource-group $STORAGE_RG \
  --location northeurope \
  --sku Standard_RAGRS \
  --kind StorageV2
{
...
  "id": "/subscriptions/dddddddd-4444-3333-2222-aaaabbbbcccc/resourceGroups/filestorage-rg/providers/Microsoft.Storage/storageAccounts/skyportentest",
...
}

# Create storage share
export STORAGE_SHARE="skyporten-share"
az storage share create --account-name $STORAGE_ACC --name $STORAGE_SHARE

# Create a text file
echo foo > ./bar.txt

# Upload the file
az storage file upload --share-name $STORAGE_SHARE --account-name $STORAGE_ACC --source ./bar.txt
```

## 6. Create role for for the service principal to read the storage account

```
# Contributor role for the service principal
az role assignment create --role contributor --subscription $SUBSCRIPTION_ID --assignee-object-id $SERVICE_PRINCIPAL_ID --assignee-principal-type ServicePrincipal --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$STORAGE_RG

# Blog access
az role assignment create --assignee "$SERVICE_PRINCIPAL_ID" \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/dddddddd-4444-3333-2222-aaaabbbbcccc/resourceGroups/$STORAGE_RG/providers/Microsoft.Storage/storageAccounts/skyportentest"

# Federated identities also need "Storage File Data Privileged..." roles
az role assignment create --assignee "$SERVICE_PRINCIPAL_ID" \
  --role "Storage File Data Privileged Reader" \
  --scope "/subscriptions/dddddddd-4444-3333-2222-aaaabbbbcccc/resourceGroups/$STORAGE_RG/providers/Microsoft.Storage/storageAccounts/skyportentest"
  
# Reader might be enough, but I added this one too
az role assignment create --assignee "$SERVICE_PRINCIPAL_ID" \
  --role "Storage File Data Privileged Contributor" \
  --scope "/subscriptions/dddddddd-4444-3333-2222-aaaabbbbcccc/resourceGroups/$STORAGE_RG/providers/Microsoft.Storage/storageAccounts/skyportentest"

```

## 7. Log in with Maskinporten credentials and download a file

```
# Logout from regular azure session, if active
az logout
```

### Get a token

See https://github.com/entur/exploratory-maskinporten-token/tree/main on how to create a token.

The token obtained must be exported to SKYPORTEN_TOKEN.

In a separate terminal
```
cd exploratory-maskinporten-token/src$ node index.js  | jq .access_token
"XqaRGpM...W4"
```

Go back to your az terminal, and login with the token.
```
export SKYPORTEN_TOKEN="XqaRGpM...W4"

# Login with skyporten OIDC token
az login --service-principal -u $SERVICE_PRINCIPAL_ID -t $AZURE_TENANT_ID --federated-token $SKYPORTEN_TOKEN

# Check that we can see bar.txt in file list
az storage file list --account-name $STORAGE_ACC --share-name $STORAGE_SHARE --auth-mode login --enable-file-backup-request-intent | jq .[0].name
"bar.txt"

# Download bar.txt
az storage file download --account-name $STORAGE_ACC --share-name $STORAGE_SHARE --auth-mode login --enable-file-backup-request-intent --path bar.txt
```
