#!/bin/bash
set -euo pipefail

# Create namespace
kubectl create namespace qa --dry-run=client -o yaml | kubectl apply -f -

# Create a secret to verify against
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
  namespace: qa
type: Opaque
data:
  username: YWRtaW4=
  password: cGFzc3dvcmQxMjM=
EOF

# Deploy Pod frontend using the default ServiceAccount
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

echo "Lab setup complete."
echo "  Namespace: qa"
echo "  Secret: db-credentials (test target)"
echo "  Pod: frontend (using default ServiceAccount)"
echo "  Task: Create SA backend-qa, Role, RoleBinding, update Pod"
