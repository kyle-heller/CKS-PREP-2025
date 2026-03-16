#!/bin/bash
echo "=== Verify: ImagePolicyWebhook ==="
PASS=true

MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"
ADMISSION_CONFIG="/etc/kubernetes/confcontrol/admission_configuration.yaml"

# Check ImagePolicyWebhook is in admission plugins
if grep -q 'ImagePolicyWebhook' "$MANIFEST"; then
  echo "[PASS] ImagePolicyWebhook is in --enable-admission-plugins"
else
  echo "[FAIL] ImagePolicyWebhook not found in admission plugins"
  PASS=false
fi

# Check admission-control-config-file flag
if grep -q '\-\-admission-control-config-file' "$MANIFEST"; then
  echo "[PASS] --admission-control-config-file flag is set"
else
  echo "[FAIL] --admission-control-config-file flag is missing"
  PASS=false
fi

# Check defaultAllow is false
if [ -f "$ADMISSION_CONFIG" ]; then
  if grep -q 'defaultAllow: false' "$ADMISSION_CONFIG"; then
    echo "[PASS] defaultAllow is set to false (implicit deny)"
  else
    echo "[FAIL] defaultAllow is not false — images will be allowed by default!"
    PASS=false
  fi
else
  echo "[FAIL] Admission configuration file not found at $ADMISSION_CONFIG"
  PASS=false
fi

# Check volume mount for confcontrol
if grep -q '/etc/kubernetes/confcontrol' "$MANIFEST"; then
  echo "[PASS] Volume mount for /etc/kubernetes/confcontrol in API server"
else
  echo "[FAIL] No volume mount for /etc/kubernetes/confcontrol in API server"
  PASS=false
fi

# Note: API server running check skipped — no webhook backend on KillerCoda.
# On the real exam, a webhook server would be running.
echo "[INFO] API server running check skipped (no webhook backend in lab)"

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
