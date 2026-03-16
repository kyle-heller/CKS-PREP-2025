#!/bin/bash
echo "=== Verify: Stateless and Immutable Pods ==="
PASS=true

# frontend should exist
if kubectl get pod frontend -n prod &>/dev/null; then
  echo "[PASS] Pod frontend exists (compliant)"
else
  echo "[FAIL] Pod frontend was deleted (it was compliant!)"
  PASS=false
fi

# app should be deleted
if ! kubectl get pod app -n prod &>/dev/null; then
  echo "[PASS] Pod app deleted (was privileged)"
else
  echo "[FAIL] Pod app still exists (privileged=true)"
  PASS=false
fi

# gcc should be deleted
if ! kubectl get pod gcc -n prod &>/dev/null; then
  echo "[PASS] Pod gcc deleted (had hostPath)"
else
  echo "[FAIL] Pod gcc still exists (had hostPath volume)"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
