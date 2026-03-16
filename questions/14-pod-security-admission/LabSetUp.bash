#!/bin/bash
set -euo pipefail
kubectl create namespace secure-team --dry-run=client -o yaml | kubectl apply -f -
kubectl label ns secure-team pod-security.kubernetes.io/enforce=restricted --overwrite

mkdir -p /home/masters
cat > /home/masters/insecure-deployment.yaml << 'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  namespace: secure-team
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
        image: nginx:1.23
        ports:
        - containerPort: 80
        securityContext:
          privileged: true
          runAsUser: 0
          capabilities:
            add: ["NET_ADMIN"]
        volumeMounts:
        - mountPath: /data
          name: host-data
      volumes:
      - name: host-data
        hostPath:
          path: /tmp
YAML

echo "Lab setup complete. Namespace: secure-team (restricted enforcement)"
echo "Deployment manifest at /home/masters/insecure-deployment.yaml"
