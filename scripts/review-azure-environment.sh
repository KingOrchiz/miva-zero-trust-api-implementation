#!/usr/bin/env bash
set -euo pipefail

if ! command -v az >/dev/null 2>&1; then
  echo "Azure CLI is not installed. Install az or run this script from a machine with Azure CLI access."
  exit 1
fi

echo "## Azure account"
az account show --output table

echo

echo "## Candidate resource groups"
az group list --query "[].{name:name,location:location,tags:tags}" --output table

echo

echo "## Candidate AKS clusters"
az aks list --query "[].{name:name,resourceGroup:resourceGroup,location:location,kubernetesVersion:kubernetesVersion,nodeResourceGroup:nodeResourceGroup,powerState:powerState.code}" --output table

echo

echo "## Candidate container registries"
az acr list --query "[].{name:name,resourceGroup:resourceGroup,location:location,loginServer:loginServer}" --output table

echo

echo "## Candidate Log Analytics workspaces"
az monitor log-analytics workspace list --query "[].{name:name,resourceGroup:resourceGroup,location:location}" --output table
