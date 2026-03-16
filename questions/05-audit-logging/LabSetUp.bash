#!/bin/bash
set -euo pipefail

# Create a minimal audit policy (student must extend it)
mkdir -p /etc/audit
cat > /etc/audit/audit-policy.yaml << 'YAML'
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  - level: None
YAML

echo "Lab setup complete."
echo "Base audit policy at /etc/audit/audit-policy.yaml"
echo "API server manifest at /etc/kubernetes/manifests/kube-apiserver.yaml"
