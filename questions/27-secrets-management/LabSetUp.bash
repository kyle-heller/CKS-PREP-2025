#!/bin/bash
set -euo pipefail

# Create namespace and secret for secrets management exercise
kubectl create namespace safe --dry-run=client -o yaml | kubectl apply -f -

# Create the existing secret that the student must decode
kubectl create secret generic admin -n safe \
  --from-literal=username=admin \
  --from-literal=password=secretpass123 \
  --dry-run=client -o yaml | kubectl apply -f -

# Create output directory
mkdir -p /home/cert-masters

echo "Lab setup complete."
echo "  Namespace: safe"
echo "  Secret: admin (with username and password)"
echo "  Output dir: /home/cert-masters/"
