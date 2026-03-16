#!/bin/bash
echo "=== Verify: KubeSec Scanning ==="
PASS=true

FILE="/home/candidate/kubesec-test.yaml"

if [ ! -f "$FILE" ]; then
  echo "[FAIL] $FILE not found"
  echo "=== SOME CHECKS FAILED ==="
  exit 1
fi

# Check 1: runAsUser is set (non-root)
if grep -q 'runAsUser:' "$FILE"; then
  echo "[PASS] runAsUser is set"
else
  echo "[FAIL] runAsUser is not set"
  PASS=false
fi

# Check 2: runAsNonRoot is set
if grep -q 'runAsNonRoot: true' "$FILE"; then
  echo "[PASS] runAsNonRoot: true"
else
  echo "[FAIL] runAsNonRoot is not set to true"
  PASS=false
fi

# Check 3: allowPrivilegeEscalation is false
if grep -q 'allowPrivilegeEscalation: false' "$FILE"; then
  echo "[PASS] allowPrivilegeEscalation: false"
else
  echo "[FAIL] allowPrivilegeEscalation is not false"
  PASS=false
fi

# Check 4: readOnlyRootFilesystem is true
if grep -q 'readOnlyRootFilesystem: true' "$FILE"; then
  echo "[PASS] readOnlyRootFilesystem: true"
else
  echo "[FAIL] readOnlyRootFilesystem is not true"
  PASS=false
fi

# Check 5: capabilities drop ALL
if grep -q 'drop:' "$FILE" && grep -A1 'drop:' "$FILE" | grep -qi 'ALL'; then
  echo "[PASS] capabilities drop ALL"
else
  echo "[FAIL] capabilities drop ALL not found"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
