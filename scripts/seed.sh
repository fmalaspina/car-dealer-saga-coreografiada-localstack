#!/usr/bin/env bash
set -euo pipefail
export AWS_ACCESS_KEY_ID=$(terraform -chdir=infra output -raw app_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(terraform -chdir=infra output -raw app_secret_access_key)
aws --endpoint-url=http://localhost:4566   sns publish --topic-arn arn:aws:sns:us-east-1:000000000000:car-events   --message '{"type":"OrderPlaced","orderId":"O-2001","model":"Sedan-X"}'
echo "Evento OrderPlaced publicado."
