#!/bin/bash
echo "=== Verify: ImagePolicyWebhook (valhalla) ==="
PASS=true

MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"
ADMISSION_CONFIG="/etc/kubernetes/imgconfig/admission_configuration.yaml"

# Check 1: defaultAllow is false (implicit deny)
if [ -f "$ADMISSION_CONFIG" ]; then
  if grep -q 'defaultAllow: false' "$ADMISSION_CONFIG"; then
    echo "[PASS] defaultAllow is false (implicit deny)"
  else
    echo "[FAIL] defaultAllow is not false"
    PASS=false
  fi
else
  echo "[FAIL] Admission configuration file not found"
  PASS=false
fi

# Check 2: ImagePolicyWebhook in admission plugins
if grep -q 'ImagePolicyWebhook' "$MANIFEST"; then
  echo "[PASS] ImagePolicyWebhook in --enable-admission-plugins"
else
  echo "[FAIL] ImagePolicyWebhook not in admission plugins"
  PASS=false
fi

# Check 3: admission-control-config-file flag points to imgconfig
if grep -q '\-\-admission-control-config-file=/etc/kubernetes/imgconfig/admission_configuration.yaml' "$MANIFEST"; then
  echo "[PASS] --admission-control-config-file points to imgconfig"
else
  echo "[FAIL] --admission-control-config-file flag missing or wrong path"
  PASS=false
fi

# Check 4: Volume mount for /etc/kubernetes/imgconfig
if grep -q '/etc/kubernetes/imgconfig' "$MANIFEST"; then
  echo "[PASS] Volume mount for /etc/kubernetes/imgconfig in API server"
else
  echo "[FAIL] No volume mount for /etc/kubernetes/imgconfig"
  PASS=false
fi

# NOTE: No "API server Running" check — no webhook backend on KillerCoda.
echo "[INFO] API server running check skipped (no webhook backend in lab)"

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
