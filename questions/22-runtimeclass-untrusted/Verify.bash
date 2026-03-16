#!/bin/bash
echo "=== Verify: RuntimeClass untrusted ==="
PASS=true

# Check 1: RuntimeClass untrusted exists with handler runsc
HANDLER=$(kubectl get runtimeclass untrusted -o jsonpath='{.handler}' 2>/dev/null)
if [ "$HANDLER" = "runsc" ]; then
  echo "[PASS] RuntimeClass untrusted has handler: runsc"
else
  echo "[FAIL] RuntimeClass untrusted not found or wrong handler (got: '$HANDLER')"
  PASS=false
fi

# Check 2: Pod untrusted exists
if kubectl get pod untrusted &>/dev/null; then
  echo "[PASS] Pod untrusted exists"
else
  echo "[FAIL] Pod untrusted not found"
  PASS=false
fi

# Check 3: Pod spec has runtimeClassName: untrusted
RC_NAME=$(kubectl get pod untrusted -o jsonpath='{.spec.runtimeClassName}' 2>/dev/null)
if [ "$RC_NAME" = "untrusted" ]; then
  echo "[PASS] Pod has runtimeClassName: untrusted"
else
  echo "[FAIL] Pod runtimeClassName is '$RC_NAME' (expected: untrusted)"
  PASS=false
fi

# Check 4: Pod spec has correct image
IMAGE=$(kubectl get pod untrusted -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
if echo "$IMAGE" | grep -q "alpine"; then
  echo "[PASS] Pod uses alpine image"
else
  echo "[FAIL] Pod image is '$IMAGE' (expected: alpine)"
  PASS=false
fi

# Check 5: Pod is scheduled on a specific node (nodeName set)
NODE_NAME=$(kubectl get pod untrusted -o jsonpath='{.spec.nodeName}' 2>/dev/null)
if [ -n "$NODE_NAME" ]; then
  echo "[PASS] Pod has nodeName: $NODE_NAME"
else
  echo "[FAIL] Pod does not have nodeName set"
  PASS=false
fi

# Check 6: dmesg output file exists
# Note: Pod may be Pending without runsc, but file should be created (even if empty placeholder)
if [ -f /opt/course/untrusted-test-dmesg ]; then
  echo "[PASS] dmesg output file exists at /opt/course/untrusted-test-dmesg"
else
  echo "[FAIL] dmesg output file not found at /opt/course/untrusted-test-dmesg"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
