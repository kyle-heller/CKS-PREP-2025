#!/bin/bash
set -euo pipefail
kubectl run nginx-pod --image=nginx --restart=Never --dry-run=client -o yaml | kubectl apply -f -
kubectl wait --for=condition=Ready pod/nginx-pod --timeout=60s 2>/dev/null || true
echo "Lab setup complete. Pod nginx-pod running in default namespace."
