#!/bin/bash
set -euo pipefail

# Clean up any existing resources from previous attempts
kubectl delete pod backend-pod --ignore-not-found=true 2>/dev/null || true
kubectl delete rolebinding pod-reader-binding --ignore-not-found=true 2>/dev/null || true
kubectl delete role pod-reader --ignore-not-found=true 2>/dev/null || true
kubectl delete sa backend-sa --ignore-not-found=true 2>/dev/null || true

echo "Lab setup complete."
echo "  Namespace: default (clean state)"
echo "  Task: Create SA, Role, RoleBinding, and Pod — see Questions.bash"
