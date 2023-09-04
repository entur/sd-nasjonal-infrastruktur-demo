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
export PROVIDER_ID=skyportenprovider
gcloud iam workload-identity-pools providers create-oidc $PROVIDER_ID \
    --location="global" \
    --workload-identity-pool=$WORKLOAD_POOL_ID \
    --attribute-mapping="attribute.maskinportenscope"="assertion.scope","google.subject"="assertion.consumer.ID","attribute.clientaccess"="\"client::\" + assertion.consumer.ID + \"::\" + assertion.scope" \
    --issuer-uri="https://sky.maskinporten.dev/" \
    --allowed-audiences="https://entur.org" \
    --description="OIDC identity pool provider for Maskinporten"

```

### Create storage bucket

```
export BUCKET="skyportenbucket"
gcloud storage buckets create gs://$BUCKET
```

### Upload a file

```
echo "bar" > foo.txt
gcloud storage cp foo.txt gs://$BUCKET/foo_remote.txt
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
export SERVICE_ACC='skyporten_storage_consumer'
gcloud iam service-accounts create $SERVICE_ACC \
    --description="Skyporten storage consumer" \
    --display-name="skyportenstoragesa"
```


#### Create policy binding
```
export SA_ROLE="skyporten_entur_"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="principalSet://iam.googleapis.com/projects/$PROJNUM/locations/global/workloadIdentityPools/$WORKLOAD_POOL_ID/attribute.clientaccess/client::$MASKINPORTENCLIENTID::$MASKINPORTENSCOPE" \
    --role="roles/iam.workloadIdentityUser"
```

#### TODO




gcloud auth login --cred-file=/path/to/workload/identity/config/file.

