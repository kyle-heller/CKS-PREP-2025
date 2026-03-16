#!/bin/bash
set -euo pipefail

# Create namespace and deployments for NetworkPolicy exercise
kubectl create namespace dev-team --dry-run=client -o yaml | kubectl apply -f -

# Deploy products-service (target of the policy)
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: products-service
  namespace: dev-team
spec:
  replicas: 1
  selector:
    matchLabels:
      app: products-service
      environment: dev
  template:
    metadata:
      labels:
        app: products-service
        environment: dev
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
EOF

# Deploy a test pod in dev-team namespace
kubectl run test-pod --namespace=dev-team --image=busybox:1.36 \
  --labels="app=tester" --command -- sleep 3600 2>/dev/null || true

# Deploy a test pod with environment=testing label in another namespace
kubectl create namespace external-team --dry-run=client -o yaml | kubectl apply -f -
kubectl run external-tester --namespace=external-team --image=busybox:1.36 \
  --labels="environment=testing" --command -- sleep 3600 2>/dev/null || true

echo "Lab setup complete."
echo "  Namespace: dev-team with products-service (environment=dev)"
echo "  Test pods in dev-team and external-team namespaces"
