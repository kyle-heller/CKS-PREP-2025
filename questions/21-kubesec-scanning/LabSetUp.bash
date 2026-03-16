#!/bin/bash
set -euo pipefail

# Create the insecure pod manifest for the student to fix
mkdir -p /home/candidate
cat > /home/candidate/kubesec-test.yaml << 'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: kubesec-demo
spec:
  containers:
    - name: kubesec-demo
      image: gcr.io/google-samples/node-hello:1.0
YAML

echo "Lab setup complete."
echo "  Insecure manifest: /home/candidate/kubesec-test.yaml"
echo "  Scan with kubesec, then apply security fixes to achieve score >= 4"
