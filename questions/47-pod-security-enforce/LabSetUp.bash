#!/bin/bash
set -euo pipefail

# Create namespace team-blue WITHOUT the pod-security label (student must add it)
kubectl create namespace team-blue --dry-run=client -o yaml | kubectl apply -f -

# Remove any existing pod-security labels (in case of re-run)
kubectl label ns team-blue pod-security.kubernetes.io/enforce- --overwrite 2>/dev/null || true

# Create Deployment with a privileged container (violates restricted profile)
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: privileged-runner
  namespace: team-blue
spec:
  replicas: 1
  selector:
    matchLabels:
      app: privileged-runner
  template:
    metadata:
      labels:
        app: privileged-runner
    spec:
      containers:
      - name: runner
        image: nginx:1.25
        command: ["sleep", "3600"]
        securityContext:
          privileged: true
          runAsUser: 0
EOF

# Wait for Pod to be running
echo "Waiting for privileged-runner Pod to start..."
kubectl wait --for=condition=Available deployment/privileged-runner -n team-blue --timeout=60s 2>/dev/null || true

# Create output directory
mkdir -p /opt/candidate/16

echo ""
echo "Lab setup complete."
echo "  Namespace: team-blue (no pod-security label yet)"
echo "  Deployment: privileged-runner (privileged: true, runAsUser: 0)"
echo "  Output dir: /opt/candidate/16/"
echo "  Task: Add restricted enforcement label, delete Pod, capture FailedCreate events"
