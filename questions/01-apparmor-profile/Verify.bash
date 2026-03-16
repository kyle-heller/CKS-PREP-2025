#!/bin/bash
echo "=== Verify: AppArmor Profile ==="
PASS=true

# Check profile is loaded
if ssh node-01 "aa-status 2>/dev/null | grep -q nginx-profile-2" 2>/dev/null || \
   aa-status 2>/dev/null | grep -q nginx-profile-2; then
  echo "[PASS] AppArmor profile nginx-profile-2 is loaded"
else
  echo "[FAIL] AppArmor profile nginx-profile-2 not found"
  PASS=false
fi

# Check Pod is running
if kubectl get pod nginx-pod -o jsonpath='{.status.phase}' 2>/dev/null | grep -q Running; then
  echo "[PASS] Pod nginx-pod is Running"
else
  echo "[FAIL] Pod nginx-pod is not Running"
  PASS=false
fi

# Check Pod is on node-01
NODE=$(kubectl get pod nginx-pod -o jsonpath='{.spec.nodeName}' 2>/dev/null)
if [ "$NODE" = "node-01" ]; then
  echo "[PASS] Pod is on node-01"
else
  echo "[FAIL] Pod is on $NODE, expected node-01"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
