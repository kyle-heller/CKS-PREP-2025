#!/bin/bash
echo "=== Verify: Trivy Scan and Delete Vulnerable Pods ==="
PASS=true

# Check 1: Namespace nato exists
if kubectl get namespace nato &>/dev/null; then
  echo "[PASS] Namespace nato exists"
else
  echo "[FAIL] Namespace nato not found"
  PASS=false
fi

# Check 2: nginx-1 (safe image) still exists
if kubectl get pod nginx-1 -n nato &>/dev/null; then
  echo "[PASS] Pod nginx-1 (nginx:1.25) still exists"
else
  echo "[FAIL] Pod nginx-1 (nginx:1.25) was deleted — it should remain"
  PASS=false
fi

# Check 3: nginx-2 (vulnerable) is deleted
if kubectl get pod nginx-2 -n nato &>/dev/null; then
  echo "[FAIL] Pod nginx-2 (nginx:1.19) still exists — should be deleted"
  PASS=false
else
  echo "[PASS] Pod nginx-2 (nginx:1.19) has been deleted"
fi

# Check 4: nginx-3 (vulnerable) is deleted
if kubectl get pod nginx-3 -n nato &>/dev/null; then
  echo "[FAIL] Pod nginx-3 (nginx:1.16) still exists — should be deleted"
  PASS=false
else
  echo "[PASS] Pod nginx-3 (nginx:1.16) has been deleted"
fi

# Check 5: Only nginx-1 remains in namespace
POD_COUNT=$(kubectl get pods -n nato --no-headers 2>/dev/null | wc -l | tr -d ' ')
if [ "$POD_COUNT" = "1" ]; then
  echo "[PASS] Exactly 1 pod remains in namespace nato"
else
  echo "[FAIL] Expected 1 pod in nato, found $POD_COUNT"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
