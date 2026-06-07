#!/usr/bin/env bash
set -euo pipefail

if ! command -v hcloud >/dev/null 2>&1 && ! command -v huaweicloud >/dev/null 2>&1; then
  echo "Huawei Cloud CLI is not installed or not configured."
  echo "Use Huawei Cloud console/API to collect: region, enterprise project, VPC, subnet, CCE cluster, ELB, DEW, LTS, and SWR/registry details."
  exit 1
fi

echo "Huawei Cloud CLI detected. Environment review commands must be finalized after confirming which CLI profile and region are configured."
