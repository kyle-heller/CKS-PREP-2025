#!/bin/bash
echo "=== Verify: PSP Restrict Volumes (manifest-only) ==="
PASS=true

FILE="/home/candidate/43/psp-solution.yaml"

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

# Check 2: PSP name is prevent-volume-policy
if grep -q 'prevent-volume-policy' "$FILE"; then
  echo "[PASS] PSP named prevent-volume-policy"
else
  echo "[FAIL] Missing PSP name prevent-volume-policy"
  PASS=false
fi

# Check 3: Allows persistentVolumeClaim volume type
if grep -q 'persistentVolumeClaim' "$FILE"; then
  echo "[PASS] Contains persistentVolumeClaim volume type"
else
  echo "[FAIL] Missing persistentVolumeClaim volume type"
  PASS=false
fi

# Check 4: Should NOT allow hostPath
if grep -q 'hostPath' "$FILE"; then
  echo "[FAIL] Contains hostPath — should only allow persistentVolumeClaim"
  PASS=false
else
  echo "[PASS] Does not allow hostPath"
fi

# Check 5: privileged: false
if grep -q 'privileged: false' "$FILE"; then
  echo "[PASS] privileged: false is set"
else
  echo "[FAIL] Missing privileged: false"
  PASS=false
fi

# Check 6: allowPrivilegeEscalation: false
if grep -q 'allowPrivilegeEscalation: false' "$FILE"; then
  echo "[PASS] allowPrivilegeEscalation: false is set"
else
  echo "[FAIL] Missing allowPrivilegeEscalation: false"
  PASS=false
fi

# Check 7: MustRunAsNonRoot
if grep -q 'MustRunAsNonRoot' "$FILE"; then
  echo "[PASS] runAsUser rule MustRunAsNonRoot is set"
else
  echo "[FAIL] Missing MustRunAsNonRoot rule"
  PASS=false
fi

# Check 8: ServiceAccount psp-sa
if grep -q 'psp-sa' "$FILE"; then
  echo "[PASS] Contains psp-sa ServiceAccount"
else
  echo "[FAIL] Missing psp-sa ServiceAccount"
  PASS=false
fi

# Check 9: ClusterRole psp-role
if grep -q 'psp-role' "$FILE"; then
  echo "[PASS] Contains psp-role"
else
  echo "[FAIL] Missing psp-role"
  PASS=false
fi

# Check 10: ClusterRoleBinding psp-role-binding
if grep -q 'psp-role-binding' "$FILE"; then
  echo "[PASS] Contains psp-role-binding"
else
  echo "[FAIL] Missing psp-role-binding"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
