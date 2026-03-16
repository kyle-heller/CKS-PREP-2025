#!/bin/bash
set -euo pipefail

# Create the frontend namespace
kubectl create namespace frontend --dry-run=client -o yaml | kubectl apply -f -

# Create the audit policy directory
mkdir -p /etc/audit

# Create skeleton audit policy file (student must add the rules)
cat > /etc/audit/audit-policy.yaml << 'YAML'
apiVersion: audit.k8s.io/v1
kind: Policy
rules: []
YAML

# Ensure log directory exists
mkdir -p /var/log

echo ""
echo "Lab setup complete."
echo "  Namespace: frontend"
echo "  Audit policy skeleton: /etc/audit/audit-policy.yaml"
echo "  API server manifest: /etc/kubernetes/manifests/kube-apiserver.yaml"
echo ""
echo "CAUTION: This question requires editing the API server manifest."
echo "The API server will restart after changes — wait ~60s for it to come back."
