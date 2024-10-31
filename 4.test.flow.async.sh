INTEGRATION_NAME=long-processing-flow
TRIGGER_ID=api_trigger/long-processing-flow-async
SECONDS=0

# start long flow for 10 minutes
curl -X POST "https://integrations.googleapis.com/v2/projects/$PROJECT_ID/locations/$REGION/integrations/$INTEGRATION_NAME:execute?triggerId=$TRIGGER_ID" \
	-H "authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json" \
    --data-binary @- << EOF
{
  "SleepInMs": "300000"
}
EOF

duration=$SECONDS
echo "Sync request finished in $((duration / 60)) minutes and $((duration % 60)) seconds."

echo "Execution started..."
