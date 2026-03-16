#!/bin/bash
set -euo pipefail

# Create namespace
kubectl create namespace test-system --dry-run=client -o yaml | kubectl apply -f -

# Create ServiceAccount
kubectl create serviceaccount sa-dev-1 -n test-system --dry-run=client -o yaml | kubectl apply -f -

# Create Pod nginx-pod using sa-dev-1
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  namespace: test-system
spec:
  serviceAccountName: sa-dev-1
  containers:
  - name: nginx
    image: nginx:1.25
    ports:
    - containerPort: 80
EOF

# Create output directory
mkdir -p /candidate

echo ""
echo "Lab setup complete."
echo "  Namespace: test-system"
echo "  ServiceAccount: sa-dev-1"
echo "  Pod: nginx-pod (uses sa-dev-1)"
echo "  Output dir: /candidate/"
echo "  Task: Find the SA, save its name, create Role and RoleBinding"
