# iRestrict Version 3 Chapter 4 Evidence Summary

Run ID: irestrict-v3-2026-06-07-173801
Collected: 2026-06-07T17:39:27+01:00

## Kubernetes context
aks-irestrict-v3-lab

## Evidence scope
This evidence bundle covers the Azure AKS deployment, Huawei CCE infrastructure provisioning, Kubernetes security workloads, and live authorization tests for the iRestrict Version 3 prototype.

## Huawei CCE access note
Huawei CCE was provisioned successfully, but its kubeconfig exposes an internal API endpoint in the 10.83.1.0/24 VPC range. The current runner cannot reach that private endpoint directly, so Kubernetes workload tests were executed on AKS while Huawei evidence is captured at infrastructure level.
