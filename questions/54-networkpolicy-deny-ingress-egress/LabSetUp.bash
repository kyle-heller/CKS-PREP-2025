#!/bin/bash
set -euo pipefail

kubectl create namespace test --dry-run=client -o yaml | kubectl apply -f -

mkdir -p /home/policy

cat > /home/policy/network-policy.yaml << 'YEOF'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-network
  namespace: test
# TODO: Complete the spec section
# Requirements:
#   - podSelector: {} (match all pods)
#   - policyTypes: Ingress and Egress
#   - No ingress or egress rules (deny all)
YEOF

echo "Lab setup complete."
echo "  Namespace: test"
echo "  Skeleton file: /home/policy/network-policy.yaml"
echo "  Task: Complete the NetworkPolicy and apply it — see Questions.bash"
