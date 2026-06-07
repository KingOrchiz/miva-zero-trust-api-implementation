#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../terraform/envs/lab"
terraform fmt -recursive
terraform init -backend=false
terraform validate
