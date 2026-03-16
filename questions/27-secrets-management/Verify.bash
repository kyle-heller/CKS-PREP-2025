#!/bin/bash
echo "=== Verify: Secrets Management ==="
PASS=true

# Check 1: username.txt exists with correct content
if [ -f /home/cert-masters/username.txt ]; then
  CONTENT=$(cat /home/cert-masters/username.txt)
  if [ "$CONTENT" = "admin" ]; then
    echo "[PASS] username.txt contains 'admin'"
  else
    echo "[FAIL] username.txt has wrong content (got: '$CONTENT', expected: 'admin')"
    PASS=false
  fi
else
  echo "[FAIL] /home/cert-masters/username.txt not found"
  PASS=false
fi

# Check 2: password.txt exists with correct content
if [ -f /home/cert-masters/password.txt ]; then
  CONTENT=$(cat /home/cert-masters/password.txt)
  if [ "$CONTENT" = "secretpass123" ]; then
    echo "[PASS] password.txt contains 'secretpass123'"
  else
    echo "[FAIL] password.txt has wrong content (got: '$CONTENT', expected: 'secretpass123')"
    PASS=false
  fi
else
  echo "[FAIL] /home/cert-masters/password.txt not found"
  PASS=false
fi

# Check 3: Secret newsecret exists in safe namespace
if kubectl get secret newsecret -n safe &>/dev/null; then
  echo "[PASS] Secret newsecret exists in safe namespace"
else
  echo "[FAIL] Secret newsecret not found in safe namespace"
  PASS=false
fi

# Check 4: newsecret has correct values
NS_USER=$(kubectl get secret newsecret -n safe -o jsonpath='{.data.username}' 2>/dev/null | base64 -d 2>/dev/null)
NS_PASS=$(kubectl get secret newsecret -n safe -o jsonpath='{.data.password}' 2>/dev/null | base64 -d 2>/dev/null)
if [ "$NS_USER" = "dbadmin" ]; then
  echo "[PASS] newsecret username is 'dbadmin'"
else
  echo "[FAIL] newsecret username is '$NS_USER' (expected: 'dbadmin')"
  PASS=false
fi
if [ "$NS_PASS" = "moresecurepas" ]; then
  echo "[PASS] newsecret password is 'moresecurepas'"
else
  echo "[FAIL] newsecret password is '$NS_PASS' (expected: 'moresecurepas')"
  PASS=false
fi

# Check 5: Pod mysecret-pod exists and mounts newsecret
if kubectl get pod mysecret-pod -n safe &>/dev/null; then
  echo "[PASS] Pod mysecret-pod exists in safe namespace"

  # Check volume mount
  VOL_SECRET=$(kubectl get pod mysecret-pod -n safe -o jsonpath='{.spec.volumes[?(@.secret.secretName=="newsecret")].name}' 2>/dev/null)
  if [ -n "$VOL_SECRET" ]; then
    echo "[PASS] Pod has volume from newsecret"
  else
    echo "[FAIL] Pod does not have a volume from newsecret"
    PASS=false
  fi
else
  echo "[FAIL] Pod mysecret-pod not found in safe namespace"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
