#!/bin/bash
echo "=== Verify: ServiceAccount Token Management ==="
PASS=true

AUTOMOUNT=$(kubectl get sa default -o jsonpath='{.automountServiceAccountToken}' 2>/dev/null)
if [ "$AUTOMOUNT" = "false" ]; then
  echo "[PASS] default SA has automountServiceAccountToken: false"
else
  echo "[FAIL] default SA automountServiceAccountToken is not false"
  PASS=false
fi

SECRET_TYPE=$(kubectl get secret default-sa-token -o jsonpath='{.type}' 2>/dev/null)
if [ "$SECRET_TYPE" = "kubernetes.io/service-account-token" ]; then
  echo "[PASS] Secret default-sa-token exists with correct type"
else
  echo "[FAIL] Secret default-sa-token not found or wrong type"
  PASS=false
fi

TOKEN=$(kubectl exec nginx-pod -- cat /var/run/secrets/kubernetes.io/serviceaccount/token 2>/dev/null)
if [ -n "$TOKEN" ]; then
  echo "[PASS] Token is mounted in the Pod"
else
  echo "[FAIL] Token not found at expected mount path"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
