#!/bin/bash
set -euo pipefail

# Create the payments namespace
kubectl create namespace payments --dry-run=client -o yaml | kubectl apply -f -

# Create a sample deployment in the namespace
kubectl create deployment payment-api -n payments --image=nginx --replicas=1 2>/dev/null || true

echo "Lab setup complete."
echo "Namespace: payments"
echo "Note: Istio is pre-installed on this cluster (simulated)."
echo "      Your task is to configure mTLS for the payments namespace."
