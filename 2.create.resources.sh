gcloud config set project $PROJECT_ID

# create service account and assign roles
gcloud iam service-accounts create "api-integration-service" \
    --description="Service account to manage api and integration automation" \
    --display-name="API Integration Service"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:api-integration-service@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/run.invoker"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:api-integration-service@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/integrations.integrationInvoker"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:api-integration-service@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/roles/pubsub.editor"

# create service
cd services/gotosleep
gcloud run deploy sleepproc --source . --region $REGION --allow-unauthenticated \
    --service-account=api-integration-service@$PROJECT_ID.iam.gserviceaccount.com \
    --timeout=1200 \
    --set-env-vars PROJECT_ID=$PROJECT_ID,TOPIC_ID=longproc
cd ../../

# create pub/sub topic
gcloud pubsub topics create longproc