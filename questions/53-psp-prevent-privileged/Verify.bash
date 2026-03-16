#!/bin/bash
echo "=== Verify: PSP Prevent Privileged (manifest-only) ==="
PASS=true

FILE="/home/candidate/53/psp-solution.yaml"

if [ ! -f "$FILE" ]; then
  echo "[FAIL] Solution file not found at $FILE"
  echo "=== SOME CHECKS FAILED ==="
  exit 1
fi

# Check 1: Contains PodSecurityPolicy kind
if grep -q 'PodSecurityPolicy' "$FILE"; then
  echo "[PASS] Contains PodSecurityPolicy resource"
else
  echo "[FAIL] Missing PodSecurityPolicy resource"
  PASS=false
fi

# Check 2: PSP named prevent-privileged-policy
if grep -q 'prevent-privileged-policy' "$FILE"; then
  echo "[PASS] PSP named prevent-privileged-policy"
else
  echo "[FAIL] Missing PSP name prevent-privileged-policy"
  PASS=false
fi

# Check 3: privileged: false
if grep -q 'privileged: false' "$FILE"; then
  echo "[PASS] privileged: false"
else
  echo "[FAIL] Missing privileged: false"
  PASS=false
fi

# Check 4: allowPrivilegeEscalation: false
if grep -q 'allowPrivilegeEscalation: false' "$FILE"; then
  echo "[PASS] allowPrivilegeEscalation: false"
else
  echo "[FAIL] Missing allowPrivilegeEscalation: false"
  PASS=false
fi

# Check 5: ClusterRole prevent-role
if grep -q 'prevent-role' "$FILE"; then
  echo "[PASS] Contains prevent-role"
else
  echo "[FAIL] Missing prevent-role"
  PASS=false
fi

# Check 6: ServiceAccount psp-sa
if grep -q 'psp-sa' "$FILE"; then
  echo "[PASS] Contains psp-sa"
else
  echo "[FAIL] Missing psp-sa"
  PASS=false
fi

# Check 7: ClusterRoleBinding prevent-role-binding
if grep -q 'prevent-role-binding' "$FILE"; then
  echo "[PASS] Contains prevent-role-binding"
else
  echo "[FAIL] Missing prevent-role-binding"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
