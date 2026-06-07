#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required."
  exit 1
fi

echo "Current kubectl context:"
kubectl config current-context

echo "This script deploys iRestrict Version 3 Kubernetes manifests to the current context."
if [[ "${DEPLOY_MIVA_CONFIRMED:-}" != "true" ]]; then
  read -r -p "Type DEPLOY-MIVA to continue: " confirm
  if [[ "$confirm" != "DEPLOY-MIVA" ]]; then
    echo "Aborted."
    exit 1
  fi
fi

kubectl apply -f "$ROOT/k8s/namespaces/namespaces.yaml"
kubectl apply -f "$ROOT/k8s/keycloak/keycloak-dev.yaml"
kubectl apply -f "$ROOT/k8s/otel/collector.yaml"
kubectl apply -f "$ROOT/k8s/opa/policies-configmap.yaml"
kubectl apply -f "$ROOT/k8s/opa/opa-deployment.yaml"
kubectl apply -f "$ROOT/k8s/spire/server.yaml"
kubectl apply -f "$ROOT/k8s/spire/agent.yaml"
kubectl apply -f "$ROOT/k8s/apps/sample-api.yaml"
kubectl apply -f "$ROOT/k8s/apps/synthetic-client.yaml"

echo "MIVA manifests submitted. Check status with scripts/collect-evidence.sh."
