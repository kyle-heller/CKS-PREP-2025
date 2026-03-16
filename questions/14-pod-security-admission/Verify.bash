#!/bin/bash
echo "=== Verify: Pod Security Admission ==="
PASS=true

READY=$(kubectl get deploy webapp -n secure-team -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [ "$READY" = "1" ]; then
  echo "[PASS] Deployment webapp is running in secure-team"
else
  echo "[FAIL] Deployment webapp is not ready (readyReplicas: $READY)"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
