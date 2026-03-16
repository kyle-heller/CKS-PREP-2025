#!/bin/bash
echo "=== Verify: docker.sock Removal ==="
PASS=true

MOUNTS=$(kubectl get deploy docker-hacker -n dev-ops -o yaml 2>/dev/null | grep "docker.sock" || true)
if [ -z "$MOUNTS" ]; then
  echo "[PASS] docker.sock mount removed from deployment"
else
  echo "[FAIL] docker.sock still mounted in deployment"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
