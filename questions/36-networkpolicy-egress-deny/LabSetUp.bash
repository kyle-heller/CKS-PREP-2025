#!/bin/bash
set -euo pipefail

# Create namespace
kubectl create namespace testing --dry-run=client -o yaml | kubectl apply -f -

# Deploy test pods to verify the policy against
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: web-app
  namespace: testing
  labels:
    app: web-app
spec:
  containers:
  - name: nginx
    image: nginx:1.25
    ports:
    - containerPort: 80
EOF

kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: test-client
  namespace: testing
  labels:
    app: test-client
spec:
  containers:
  - name: busybox
    image: busybox:1.36
    command: ["sleep", "3600"]
EOF

echo "Lab setup complete."
echo "  Namespace: testing"
echo "  Pods: web-app (nginx:1.25), test-client (busybox:1.36)"
echo "  Task: Create NetworkPolicy default-deny to block all egress"
