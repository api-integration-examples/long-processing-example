INTEGRATION_NAME=long-processing-flow
INTEGRATION_SNAPSHOT=24
INTEGRATION_PROJECT_ID=apigee-test85
INTEGRATION_REGION=europe-west3

integrationcli integrations scaffold -n $INTEGRATION_NAME -s $INTEGRATION_SNAPSHOT -f integrations -e dev -p $INTEGRATION_PROJECT_ID -t $(gcloud auth print-access-token) -r $INTEGRATION_REGION