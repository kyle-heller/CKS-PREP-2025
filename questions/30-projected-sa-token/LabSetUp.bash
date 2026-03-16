#!/bin/bash
set -euo pipefail

# Create a basic pod without projected volume (student must recreate with projected token)
kubectl delete pod token-demo --ignore-not-found --grace-period=0 --force &>/dev/null || true
sleep 2

kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: token-demo
  namespace: default
spec:
  containers:
  - name: nginx
    image: nginx
EOF

kubectl wait --for=condition=Ready pod/token-demo --timeout=60s &>/dev/null || true

echo "Lab setup complete."
echo "  Pod: token-demo (basic, no projected volume)"
echo "  Disable automount on default SA"
echo "  Recreate pod with projected serviceAccountToken"
