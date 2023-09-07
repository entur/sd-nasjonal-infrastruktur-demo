# Bruk av workload identity federation med Maskinporten mot GCP



### Login i gcloud with your personal cloud user

```
gcloud auth login
```

### Set google project

```
export GOOGLE_PROJECT=<dittprosjekt>
```

```
gcloud config set project "$GOOGLE_PROJECT"
```


### Create a new workload identity pool

```
export WORKLOAD_POOL_ID=skyportenpoc
gcloud iam workload-identity-pools create "$WORKLOAD_POOL_ID" \
    --location="global" \
    --description="pool for skyporten poc" \
    --display-name="skyportenpoc"
```

### Define oidc identity pool provider

```
export ENTUR_AUDIENCE="https://entur.org"
export PROVIDER_ID=skyportenprovider
gcloud iam workload-identity-pools providers create-oidc $PROVIDER_ID \
    --location="global" \
    --workload-identity-pool=$WORKLOAD_POOL_ID \
    --attribute-mapping="attribute.maskinportenscope"="assertion.scope","google.subject"="assertion.consumer.ID","attribute.clientaccess"="\"client::\" + assertion.consumer.ID + \"::\" + assertion.scope" \
    --issuer-uri="https://sky.maskinporten.dev/" \
    --allowed-audiences=$ENTUR_AUDIENCE \
    --description="OIDC identity pool provider for Maskinporten"

```

### Create storage bucket

```
export BUCKET="skyportenbucket"
gcloud storage buckets create gs://$BUCKET --location="EUROPE-WEST4"
```

### Upload a file

```
echo "bar" > foo.txt
gcloud storage cp foo.txt gs://$BUCKET/foo_remote.txt
Copying file://foo.txt to gs://skyportenbucket/foo_remote.txt
  Completed files 1/1 | 4.0B/4.0B

gcloud storage ls gs://$BUCKET
gs://skyportenbucket/foo_remote.txt
```

### Create a service account and make pool a member

#### Get project number

```
# find proj num in projects list
gcloud projects list

# Export project number
export PROJNUM=[ number ]
```

```
export MASKINPORTENCLIENTID="0192:917422575"
export MASKINPORTENSCOPE="entur:skyss.1"
export SERVICE_ACC='skyportenstorageconsumer'
gcloud iam service-accounts create $SERVICE_ACC \
    --description="Skyporten storage consumer" \
    --display-name="skyportenstoragesa"
```

#### Extract the email from the created SA

```
gcloud iam service-accounts list
skyportenstoragesa                         skyportenstorageconsumer@[project_id].iam.gserviceaccount.com        False

export SAEMAIL="skyportenstorageconsumer@[project_id].iam.gserviceaccount.com"
```

export SAEMAIL="skyportenstorageconsumer@ent-data-sdsharing-ext-dev.iam.gserviceaccount.com"


#### Create policy binding
```
gcloud iam service-accounts add-iam-policy-binding $SAEMAIL \
    --member="principalSet://iam.googleapis.com/projects/$PROJNUM/locations/global/workloadIdentityPools/$WORKLOAD_POOL_ID/attribute.clientaccess/client::$MASKINPORTENCLIENTID::$MASKINPORTENSCOPE" \
    --role="roles/viewer"
```

gcloud iam service-accounts add-iam-policy-binding $SAEMAIL \
    --member="principalSet://iam.googleapis.com/projects/$PROJNUM/locations/global/workloadIdentityPools/$WORKLOAD_POOL_ID/attribute.clientaccess/client::$MASKINPORTENCLIENTID::$MASKINPORTENSCOPE" \
    --role="roles/iam.workloadIdentityUser"


gcloud projects add-iam-policy-binding $GOOGLE_PROJECT \
--member='serviceAccount:$SAEMAIL' \
--role="roles/storage.objectViewer"




#### Create policy

resource "google_service_account_iam_policy" "foo" {
  service_account_id = google_service_account.consumer_scope_user.name
  policy_data        = data.google_iam_policy.clientaccess.policy_data
}


## Login with STS token

```
export SUBJECT_TOKEN_TYPE="urn:ietf:params:oauth:token-type:jwt"
export SUBJECT_TOKEN=`cat tmp_maskinporten_access_token.json | jq -r .access_token`
export AUDIENCE_ID="//iam.googleapis.com/projects/${PROJNUM}/locations/global/workloadIdentityPools/$WORKLOAD_POOL_ID/providers/${PROVIDER_ID}"
echo "AUDIENCE_ID: $AUDIENCE_ID"

export SUBJECT_TOKEN=`cat tmp_maskinporten_access_token.json | jq -r .access_token`
curl https://sts.googleapis.com/v1/token \
    --data-urlencode "audience=$AUDIENCE_ID" \
    --data-urlencode "grant_type=urn:ietf:params:oauth:grant-type:token-exchange" \
    --data-urlencode "requested_token_type=urn:ietf:params:oauth:token-type:access_token" \
    --data-urlencode "scope=https://www.googleapis.com/auth/cloud-platform" \
    --data-urlencode "subject_token_type=$SUBJECT_TOKEN_TYPE" \
    --data-urlencode "subject_token=$SUBJECT_TOKEN" > tmp_sts_access_token.txt
    
export STS_TOKEN=$(curl https://sts.googleapis.com/v1/token \
    --data-urlencode "audience=$AUDIENCE_ID" \
    --data-urlencode "grant_type=urn:ietf:params:oauth:grant-type:token-exchange" \
    --data-urlencode "requested_token_type=urn:ietf:params:oauth:token-type:access_token" \
    --data-urlencode "scope=https://www.googleapis.com/auth/cloud-platform" \
    --data-urlencode "subject_token_type=$SUBJECT_TOKEN_TYPE" \
    --data-urlencode "subject_token=$SUBJECT_TOKEN" | jq -r .access_token)
echo $STS_TOKEN
```

#### TODO


gcloud storage ls gs://$BUCKET --access-token-file=tmp_sts_access_token.txt

gcloud auth login --access-token-file=tmp_sts_access_token.txt

--access-token-file=tmp_sts_access_token.txt

gcloud auth login --cred-file=/path/to/workload/identity/config/file.


gcloud storage ls gs://$BUCKET
