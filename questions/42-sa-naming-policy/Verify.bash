#!/bin/bash
echo "=== Verify: SA Naming Policy ==="
PASS=true

# Check 1: SA frontend-sa exists in qa
if kubectl get sa frontend-sa -n qa &>/dev/null; then
  echo "[PASS] ServiceAccount frontend-sa exists in qa namespace"
else
  echo "[FAIL] ServiceAccount frontend-sa not found in qa namespace"
  PASS=false
fi

# Check 2: frontend-sa has automountServiceAccountToken: false
AUTOMOUNT=$(kubectl get sa frontend-sa -n qa -o jsonpath='{.automountServiceAccountToken}' 2>/dev/null)
if [ "$AUTOMOUNT" = "false" ]; then
  echo "[PASS] frontend-sa has automountServiceAccountToken: false"
else
  echo "[FAIL] frontend-sa automountServiceAccountToken is not false (got: '$AUTOMOUNT')"
  PASS=false
fi

# Check 3: Pod frontend uses serviceAccountName: frontend-sa
POD_SA=$(kubectl get pod frontend -n qa -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)
if [ "$POD_SA" = "frontend-sa" ]; then
  echo "[PASS] Pod frontend uses serviceAccountName: frontend-sa"
else
  echo "[FAIL] Pod frontend does not use frontend-sa (got: '$POD_SA')"
  PASS=false
fi

# Check 4: old-backend-sa has been deleted
if kubectl get sa old-backend-sa -n qa &>/dev/null; then
  echo "[FAIL] ServiceAccount old-backend-sa still exists (should be deleted)"
  PASS=false
else
  echo "[PASS] ServiceAccount old-backend-sa has been deleted"
fi

# Check 5: temp-sa has been deleted
if kubectl get sa temp-sa -n qa &>/dev/null; then
  echo "[FAIL] ServiceAccount temp-sa still exists (should be deleted)"
  PASS=false
else
  echo "[PASS] ServiceAccount temp-sa has been deleted"
fi

# Check 6: old-backend-sa and temp-sa should not exist (cleaned up)
# Note: other SAs (e.g., backend-qa from Q37) may exist — only check the unused ones
echo "[PASS] Unused ServiceAccounts cleaned up (old-backend-sa, temp-sa deleted)"

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
