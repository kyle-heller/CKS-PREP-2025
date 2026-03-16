#!/bin/bash
set -euo pipefail

# Create namespace for john
kubectl create namespace john --dry-run=client -o yaml | kubectl apply -f -

# Generate john's private key and CSR
mkdir -p /home/candidate
openssl genrsa -out /home/candidate/john.key 3072 2>/dev/null
openssl req -new -key /home/candidate/john.key -out /home/candidate/john.csr \
  -subj "/CN=john/O=devs" 2>/dev/null

# Clean up any pre-existing CSR
kubectl delete csr john-csr --ignore-not-found &>/dev/null || true

echo "Lab setup complete."
echo "  Namespace: john"
echo "  Key: /home/candidate/john.key"
echo "  CSR: /home/candidate/john.csr"
echo "  Create a CSR resource, approve it, set up kubeconfig, Role, and RoleBinding."
