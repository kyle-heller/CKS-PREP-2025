#!/bin/bash
set -euo pipefail
mkdir -p /etc/audit
cat > /etc/audit/audit-policy.yaml << 'YAML'
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  - level: None
YAML
echo "Lab setup complete. Edit /etc/audit/audit-policy.yaml and kube-apiserver manifest."
