#!/bin/bash
set -euo pipefail

# Create namespace
kubectl create namespace secure-app --dry-run=client -o yaml | kubectl apply -f -

# Create the seccomp profiles directory (but don't create the profile — student must do that)
mkdir -p /var/lib/kubelet/seccomp/profiles

# Create a Deployment without seccomp profile (student must add it)
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  namespace: secure-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: nginx:1.25
        ports:
        - containerPort: 80
EOF

echo "Lab setup complete."
echo "  Namespace: secure-app with Deployment webapp (no seccomp profile)"
echo "  Seccomp dir: /var/lib/kubelet/seccomp/profiles/"
echo "  Task: Create seccomp profile and apply to Deployment"
