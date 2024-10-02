SECONDS=0

curl -X POST \
	"https://integrations.googleapis.com/v1/projects/$PROJECT_ID/locations/$REGION/integrations/-:execute" \
	-H "authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data-binary @- << EOF
    
{
  "trigger_id":"api_trigger/long-processing-flow-sync"
}
EOF

duration=$SECONDS
echo "Sync request finished in $((duration / 60)) minutes and $((duration % 60)) seconds."