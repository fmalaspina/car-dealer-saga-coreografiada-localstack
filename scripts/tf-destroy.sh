#!/usr/bin/env bash
set -euo pipefail
pushd infra >/dev/null
terraform destroy -auto-approve || true
popd >/dev/null
