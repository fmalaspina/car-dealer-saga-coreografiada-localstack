#!/usr/bin/env bash
set -euo pipefail
APP_ACCESS_KEY=$(terraform -chdir=infra output -raw app_access_key_id)
APP_SECRET_KEY=$(terraform -chdir=infra output -raw app_secret_access_key)
cat > .env <<EOF
APP_ACCESS_KEY=$APP_ACCESS_KEY
APP_SECRET_KEY=$APP_SECRET_KEY
EOF
echo "Escribí credenciales en .env"
