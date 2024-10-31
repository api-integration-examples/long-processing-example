# enable services
gcloud services enable artifactregistry.googleapis.com --project $PROJECT_ID
gcloud services enable cloudbuild.googleapis.com --project $PROJECT_ID
gcloud services enable run.googleapis.com --project $PROJECT_ID
gcloud services enable storage.googleapis.com --project $PROJECT_ID
gcloud services enable integrations.googleapis.com --project $PROJECT_ID
gcloud services enable connectors.googleapis.com --project $PROJECT_ID

# create service account and assign roles
gcloud iam service-accounts create "api-integration-service" \
    --description="Service account to manage api and integration automation" \
    --display-name="API Integration Service" --project $PROJECT_ID

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:api-integration-service@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/run.invoker"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:api-integration-service@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/integrations.integrationInvoker"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:api-integration-service@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/pubsub.editor"

PROJECTNUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:service-$PROJECTNUMBER@gcp-sa-integrations.iam.gserviceaccount.com" \
    --role='roles/pubsub.editor'

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:service-$PROJECTNUMBER@gcp-sa-integrations.iam.gserviceaccount.com" \
    --role='roles/iam.serviceAccountUser'

# create service
SECONDS=0
cd services/gotosleep
gcloud run deploy sleepproc --source . --region $REGION --project $PROJECT_ID --no-allow-unauthenticated \
    --service-account=api-integration-service@$PROJECT_ID.iam.gserviceaccount.com --timeout=1200 \
    --set-env-vars PROJECT_ID=$PROJECT_ID,TOPIC_ID=longproc
cd ../../
duration=$SECONDS
echo "Deployment finished in $((duration / 60)) minutes and $((duration % 60)) seconds."
SERVICE_URL=$(gcloud run services describe sleepproc --format 'value(status.url)' --region $REGION --project $PROJECT_ID)

# create pub/sub topic
gcloud pubsub topics create longproc --project $PROJECT_ID

# replace integration variables
sed -i "/			\"serviceAccountEmail\": /c\			\"serviceAccountEmail\": \"api-integration-service@$PROJECT_ID.iam.gserviceaccount.com\"," integrations/dev/authconfigs/IntegrationService.json
sed -i "/			\"audience\": /c\			\"audience\": \"$SERVICE_URL\"" integrations/dev/authconfigs/IntegrationService.json
sed -i "/	\"\`CONFIG_SleepServiceUrl\`\": /c\	\"\`CONFIG_SleepServiceUrl\`\": \"$SERVICE_URL/sleep\"" integrations/dev/config-variables/long-processing-flow-config.json
sed -i "s/apigee-test85/$PROJECT_ID/g" integrations/src/long-processing-flow.json
sed -i "s,https://sleepproc-693189995131.europe-west3.run.app,$SERVICE_URL,g" integrations/src/long-processing-flow.json
sed -i "s/apigee-test85/$PROJECT_ID/g" integrations/dev/overrides/overrides.json

# create integration
cd integrations
integrationcli integrations apply -f . -e dev --wait=true -p $PROJECT_ID -t $(gcloud auth print-access-token) -r $REGION --sa int-service --sp $PROJECT_ID
cd ..