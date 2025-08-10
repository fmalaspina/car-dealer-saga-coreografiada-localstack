#!/usr/bin/env bash
set -euo pipefail
pushd infra >/dev/null
terraform init -input=false
terraform apply -auto-approve
popd >/dev/null
