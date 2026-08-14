#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${IRESTRICT_TARGET_CLOUD:-}"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required."
  exit 1
fi

if [[ "$TARGET" != "azure" && "$TARGET" != "huawei" ]]; then
  echo "Set IRESTRICT_TARGET_CLOUD to azure or huawei." >&2
  exit 2
fi

CONTEXT="$(kubectl config current-context)"
echo "Current kubectl context: $CONTEXT"
case "$TARGET:$CONTEXT" in
  azure:irestrict-azure|huawei:external|huawei:externalTLSVerify) ;;
  *)
    echo "Refusing deployment: context '$CONTEXT' is not approved for target '$TARGET'." >&2
    exit 2
    ;;
esac

kubectl get nodes >/dev/null
echo "Verified reachable target: $TARGET"

echo "This script deploys iRestrict laboratory Kubernetes manifests to the current context."
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
kubectl apply -f "$ROOT/k8s/spire/rbac.yaml"
kubectl apply -f "$ROOT/k8s/spire/server.yaml"
kubectl apply -f "$ROOT/k8s/spire/agent.yaml"
kubectl apply -f "$ROOT/k8s/apps/sample-api.yaml"
kubectl apply -f "$ROOT/k8s/apps/synthetic-client.yaml"

for deployment in \
  irestrict-identity/keycloak \
  irestrict-observability/otel-collector \
  irestrict-security/opa \
  irestrict-apps/sample-financial-api; do
  namespace="${deployment%%/*}"
  name="${deployment##*/}"
  kubectl -n "$namespace" rollout status "deployment/$name" --timeout=10m
done
kubectl -n irestrict-security rollout status statefulset/spire-server --timeout=10m
kubectl -n irestrict-security rollout status daemonset/spire-agent --timeout=10m

echo "MIVA manifests submitted and core rollouts completed on $TARGET."
