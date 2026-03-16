#!/bin/bash
set -euo pipefail

# Create namespace
kubectl create namespace ci-cd --dry-run=client -o yaml | kubectl apply -f -

# Deploy pod docker-builder with docker.sock mount and NO securityContext
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: docker-builder
  namespace: ci-cd
  labels:
    app: docker-builder
spec:
  containers:
  - name: builder
    image: docker:24-dind
    command: ["sleep", "3600"]
    volumeMounts:
    - name: dockersock
      mountPath: /var/run/docker.sock
  volumes:
  - name: dockersock
    hostPath:
      path: /var/run/docker.sock
EOF

echo "Lab setup complete."
echo "  Namespace: ci-cd"
echo "  Pod: docker-builder (docker:24-dind, mounts /var/run/docker.sock)"
echo "  Task: Restrict socket permissions and add securityContext"
