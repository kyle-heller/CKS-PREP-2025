#!/bin/bash
set -euo pipefail

kubectl create namespace staging --dry-run=client -o yaml | kubectl apply -f -
kubectl run nginx -n staging --image=nginx --labels="app=web" --dry-run=client -o yaml | kubectl apply -f -
kubectl run test-pod -n staging --image=busybox --command --dry-run=client -o yaml -- sleep 3600 | kubectl apply -f -

echo "Lab setup complete."
echo "  Namespace: staging"
echo "  Pods: nginx (app=web), test-pod"
echo "  Task: Create NetworkPolicy allow-np — see Questions.bash"
