#!/bin/bash
set -euo pipefail

# Create namespace
kubectl create namespace qa --dry-run=client -o yaml | kubectl apply -f -

# Create unused ServiceAccounts (student must delete these)
kubectl create serviceaccount old-backend-sa -n qa --dry-run=client -o yaml | kubectl apply -f -
kubectl create serviceaccount temp-sa -n qa --dry-run=client -o yaml | kubectl apply -f -

# Create Pod "frontend" using default SA
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  namespace: qa
  labels:
    app: frontend
spec:
  containers:
  - name: frontend
    image: nginx:1.25
    ports:
    - containerPort: 80
EOF

kubectl wait --for=condition=Ready pod/frontend -n qa --timeout=60s 2>/dev/null || true

echo "Lab setup complete."
echo "  Namespace: qa"
echo "  Pod: frontend (using default SA)"
echo "  ServiceAccounts in qa: default, old-backend-sa, temp-sa"
echo "  Task: Create frontend-sa, update Pod, clean up unused SAs"
