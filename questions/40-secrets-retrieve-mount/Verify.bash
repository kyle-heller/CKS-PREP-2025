#!/bin/bash
echo "=== Verify: Secrets Retrieve and Mount ==="
echo ""
PASS=true

# ---- Part 1: Decoded secret saved to file ----

# Check 1: ca.crt file exists and is non-empty
if [ -f /home/candidate/ca.crt ]; then
  if [ -s /home/candidate/ca.crt ]; then
    echo "[PASS] /home/candidate/ca.crt exists and is non-empty"
  else
    echo "[FAIL] /home/candidate/ca.crt exists but is empty"
    PASS=false
  fi
else
  echo "[FAIL] /home/candidate/ca.crt not found"
  PASS=false
fi

# ---- Part 2: Secret app-config-secret in app namespace ----

# Check 2: Secret exists
if kubectl get secret app-config-secret -n app &>/dev/null; then
  echo "[PASS] Secret app-config-secret exists in app namespace"
else
  echo "[FAIL] Secret app-config-secret not found in app namespace"
  PASS=false
fi

# Check 3: Secret has correct APP_USER value
APP_USER=$(kubectl get secret app-config-secret -n app -o jsonpath='{.data.APP_USER}' 2>/dev/null | base64 -d 2>/dev/null)
if [ "$APP_USER" = "appadmin" ]; then
  echo "[PASS] APP_USER is 'appadmin'"
else
  echo "[FAIL] APP_USER is '$APP_USER' (expected: 'appadmin')"
  PASS=false
fi

# Check 4: Secret has correct APP_PASS value
APP_PASS=$(kubectl get secret app-config-secret -n app -o jsonpath='{.data.APP_PASS}' 2>/dev/null | base64 -d 2>/dev/null)
if [ "$APP_PASS" = "Sup3rS3cret" ]; then
  echo "[PASS] APP_PASS is 'Sup3rS3cret'"
else
  echo "[FAIL] APP_PASS is '$APP_PASS' (expected: 'Sup3rS3cret')"
  PASS=false
fi

# ---- Part 3: Pod app-pod with secret volume mount ----

# Check 5: Pod exists in app namespace
if kubectl get pod app-pod -n app &>/dev/null; then
  echo "[PASS] Pod app-pod exists in app namespace"
else
  echo "[FAIL] Pod app-pod not found in app namespace"
  PASS=false
fi

# Check 6: Pod has a volume sourced from app-config-secret
VOL_SECRET=$(kubectl get pod app-pod -n app -o jsonpath='{.spec.volumes[?(@.secret.secretName=="app-config-secret")].name}' 2>/dev/null)
if [ -n "$VOL_SECRET" ]; then
  echo "[PASS] Pod has volume from app-config-secret"
else
  echo "[FAIL] Pod does not have a volume sourced from app-config-secret"
  PASS=false
fi

# Check 7: Pod mounts the secret at /etc/app-config
MOUNT_PATH=$(kubectl get pod app-pod -n app -o jsonpath='{.spec.containers[0].volumeMounts[?(@.name=="'"$VOL_SECRET"'")].mountPath}' 2>/dev/null)
if [ "$MOUNT_PATH" = "/etc/app-config" ]; then
  echo "[PASS] Secret mounted at /etc/app-config"
else
  echo "[FAIL] Secret not mounted at /etc/app-config (found: '$MOUNT_PATH')"
  PASS=false
fi

echo ""
$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
