#!/bin/bash
set -euo pipefail
kubectl create namespace dev-ops --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: docker-hacker
  namespace: dev-ops
spec:
  replicas: 1
  selector:
    matchLabels:
      app: docker-hacker
  template:
    metadata:
      labels:
        app: docker-hacker
    spec:
      containers:
      - name: container1
        image: nginx
        volumeMounts:
        - name: dockersock
          mountPath: /var/run/docker.sock
      volumes:
      - name: dockersock
        hostPath:
          path: /var/run/docker.sock
EOF

echo "Lab setup complete. Namespace: dev-ops, Deployment: docker-hacker"
