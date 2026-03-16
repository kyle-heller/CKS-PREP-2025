#!/bin/bash
set -euo pipefail

# Create the working directory
mkdir -p /home/candidate/10

# Write the insecure Dockerfile
cat > /home/candidate/10/Dockerfile << 'DEOF'
FROM ubuntu:latest
RUN apt-get update && apt-get install -y wget gnupg2
RUN wget -qO- https://packages.couchbase.com/releases/couchbase-release/couchbase-release-1.0-amd64.deb | dpkg -i - || true
RUN apt-get update && apt-get install -y couchbase-server
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
USER root
DEOF

# Write the insecure Deployment manifest
cat > /home/candidate/10/deployment.yaml << 'YEOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: couchbase
  labels:
    app: couchbase
spec:
  replicas: 1
  selector:
    matchLabels:
      app: couchbase
  template:
    metadata:
      labels:
        app: couchbase
    spec:
      containers:
      - name: couchbase
        image: couchbase:enterprise-7.1.1
        ports:
        - containerPort: 8091
        securityContext:
          runAsUser: 0
          privileged: true
          allowPrivilegeEscalation: false
YEOF

echo ""
echo "Lab setup complete."
echo "  Dockerfile: /home/candidate/10/Dockerfile"
echo "  Deployment: /home/candidate/10/deployment.yaml"
echo ""
echo "Fix two issues in each file. Use UID 65535 (nobody) for the non-root user."
