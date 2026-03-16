#!/bin/bash
set -euo pipefail
mkdir -p /etc/kubernetes/enc
kubectl create secret generic test-unencrypted -n default --from-literal=key=plaintext 2>/dev/null || true
echo "Lab setup complete. A test secret exists in default namespace."
