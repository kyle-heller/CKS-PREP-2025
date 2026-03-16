#!/bin/bash
set -euo pipefail

mkdir -p /home/manifests

cat > /home/manifests/Dockerfile << 'DEOF'
FROM ubuntu:latest
RUN apt-get update -y && apt-get install -y wget gnupg2
RUN wget -qO - https://packages.confluent.io/deb/7.0/archive.key | apt-key add -
RUN apt-get update -y && apt-get install -y confluent-kafka
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
USER root
DEOF

cat > /home/manifests/deployment.yaml << 'YEOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kafka-deploy
  labels:
    app: kafka
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kafka
  template:
    metadata:
      labels:
        app: kafka
    spec:
      containers:
      - name: kafka
        image: local/kafka:1.0
        securityContext:
          runAsUser: 0
          privileged: true
          readOnlyRootFilesystem: false
        ports:
        - containerPort: 9092
YEOF

echo "Lab setup complete. Files at /home/manifests/"
echo "  - Dockerfile (insecure base image + root user)"
echo "  - deployment.yaml (insecure securityContext)"
