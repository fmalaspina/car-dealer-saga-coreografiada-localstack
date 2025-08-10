#!/usr/bin/env bash
set -euo pipefail
docker compose up -d --build
./scripts/tf-apply.sh
./scripts/gen-env.sh
docker compose up -d --build
echo "LocalStack + Infra + Apps arriba."
