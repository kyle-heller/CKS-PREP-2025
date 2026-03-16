#!/bin/bash
echo "=== Verify: Encryption at Rest ==="
PASS=true

MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"
ENC_FILE="/etc/kubernetes/enc/enc.yaml"

# Check encryption-provider-config flag in API server
if grep -q '\-\-encryption-provider-config=/etc/kubernetes/enc/enc.yaml' "$MANIFEST"; then
  echo "[PASS] API server has --encryption-provider-config flag"
else
  echo "[FAIL] API server missing --encryption-provider-config=/etc/kubernetes/enc/enc.yaml"
  PASS=false
fi

# Check enc.yaml exists and contains aescbc
if [ -f "$ENC_FILE" ]; then
  echo "[PASS] Encryption config file exists at $ENC_FILE"
  if grep -q 'aescbc' "$ENC_FILE"; then
    echo "[PASS] Encryption config uses aescbc provider"
  else
    echo "[FAIL] Encryption config does not contain aescbc provider"
    PASS=false
  fi
  if grep -q 'identity' "$ENC_FILE"; then
    echo "[PASS] Encryption config has identity fallback provider"
  else
    echo "[WARN] No identity fallback provider (optional but recommended)"
  fi
else
  echo "[FAIL] Encryption config file not found at $ENC_FILE"
  PASS=false
fi

# Check volume mount exists in API server manifest
if grep -q '/etc/kubernetes/enc' "$MANIFEST"; then
  echo "[PASS] Volume mount for /etc/kubernetes/enc in API server manifest"
else
  echo "[FAIL] No volume mount for /etc/kubernetes/enc in API server manifest"
  PASS=false
fi

# Check API server is running
if kubectl get pods -n kube-system -l component=kube-apiserver --no-headers 2>/dev/null | grep -q Running; then
  echo "[PASS] API server pod is Running"
else
  echo "[FAIL] API server pod is not Running — check manifest for errors"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
