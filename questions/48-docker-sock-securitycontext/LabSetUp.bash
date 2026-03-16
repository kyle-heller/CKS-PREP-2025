#!/bin/bash
set -euo pipefail

# Create namespace
kubectl create namespace sandbox --dry-run=client -o yaml | kubectl apply -f -

# Deploy docker-admin with docker.sock mount and NO securityContext (insecure)
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: docker-admin
  namespace: sandbox
spec:
  replicas: 1
  selector:
    matchLabels:
      app: docker-admin
  template:
    metadata:
      labels:
        app: docker-admin
    spec:
      containers:
      - name: docker-admin
        image: docker:24-cli
        command: ["sleep", "3600"]
        volumeMounts:
        - name: dockersock
          mountPath: /var/run/docker.sock
      volumes:
      - name: dockersock
        hostPath:
          path: /var/run/docker.sock
EOF

echo ""
echo "Lab setup complete."
echo "  Namespace: sandbox"
echo "  Deployment: docker-admin (docker:24-cli, mounts /var/run/docker.sock)"
echo "  No securityContext is set -- container runs as root with full capabilities"
echo "  Task: Harden securityContext without removing the docker.sock mount"
