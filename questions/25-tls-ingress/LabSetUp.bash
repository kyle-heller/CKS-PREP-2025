#!/bin/bash
set -euo pipefail

# Create namespace
kubectl create namespace testing --dry-run=client -o yaml | kubectl apply -f -

# Generate self-signed certificate for bingo.com
mkdir -p /home/candidate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /home/candidate/bingo.key \
  -out /home/candidate/bingo.crt \
  -subj "/CN=bingo.com/O=bingo" 2>/dev/null

echo "Lab setup complete."
echo "  Namespace: testing"
echo "  Certificate: /home/candidate/bingo.crt"
echo "  Key: /home/candidate/bingo.key"
echo "  Create TLS Secret, deploy nginx-pod, Service, and Ingress with TLS"
