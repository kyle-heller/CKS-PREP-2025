#!/bin/bash
echo "=== Verify: PodSecurityPolicy (manifest-only) ==="
PASS=true

FILE="/home/candidate/23/psp-solution.yaml"

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

# Check 2: privileged: false
if grep -q 'privileged: false' "$FILE"; then
  echo "[PASS] privileged: false"
else
  echo "[FAIL] Missing privileged: false"
  PASS=false
fi

# Check 3: PSP name is prevent-psp-policy
if grep -q 'prevent-psp-policy' "$FILE"; then
  echo "[PASS] PSP named prevent-psp-policy"
else
  echo "[FAIL] Missing PSP name prevent-psp-policy"
  PASS=false
fi

# Check 4: ClusterRole restrict-access-role
if grep -q 'restrict-access-role' "$FILE"; then
  echo "[PASS] Contains restrict-access-role"
else
  echo "[FAIL] Missing restrict-access-role"
  PASS=false
fi

# Check 5: ServiceAccount psp-restrict-sa
if grep -q 'psp-restrict-sa' "$FILE"; then
  echo "[PASS] Contains psp-restrict-sa"
else
  echo "[FAIL] Missing psp-restrict-sa"
  PASS=false
fi

# Check 6: ClusterRoleBinding restrict-access-bind
if grep -q 'restrict-access-bind' "$FILE"; then
  echo "[PASS] Contains restrict-access-bind"
else
  echo "[FAIL] Missing restrict-access-bind"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
