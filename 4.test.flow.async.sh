SECONDS=0

EXECUTION_ID=$(curl -X POST \
	"https://integrations.googleapis.com/v1/projects/$PROJECT_ID/locations/$REGION/integrations/-:execute" \
	-H "authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data-binary @- << EOF | jq --raw-output ".executionId"

{
  "trigger_id":"api_trigger/long-processing-flow-async"
}
EOF
)

duration=$SECONDS
echo "Sync request finished in $((duration / 60)) minutes and $((duration % 60)) seconds."

echo "Execution $EXECUTION_ID started"

curl -X GET \
	"https://integrations.googleapis.com/v1/projects/$PROJECT_ID/locations/$REGION/integrations/long-processing-flow/executions/$EXECUTION_ID" \
	-H "authorization: Bearer $(gcloud auth print-access-token)"