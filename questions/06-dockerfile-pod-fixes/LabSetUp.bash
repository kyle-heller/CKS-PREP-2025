#!/bin/bash
set -euo pipefail
mkdir -p /home/candidate/06

cat > /home/candidate/06/Dockerfile << 'DEOF'
FROM ubuntu:latest
RUN apt-get update -y
RUN apt-get install nginx -y
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
USER ROOT
DEOF

cat > /home/candidate/06/pod.yaml << 'YEOF'
apiVersion: v1
kind: Pod
metadata:
  name: security-context-demo-2
spec:
  securityContext:
    runAsUser: 1000
  containers:
  - name: security-context-demo-2
    image: gcr.io/google-samples/node-hello:1.0
    securityContext:
      runAsUser: 0
      privileged: true
      allowPrivilegeEscalation: false
YEOF

echo "Lab setup complete. Files at /home/candidate/06/"
