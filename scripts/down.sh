#!/usr/bin/env bash
set -euo pipefail
./scripts/tf-destroy.sh || true
docker compose down -v
echo "Entorno apagado."
