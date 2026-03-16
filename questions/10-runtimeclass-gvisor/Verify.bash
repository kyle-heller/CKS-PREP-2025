#!/bin/bash
echo "=== Verify: RuntimeClass with gVisor ==="
PASS=true

# Check RuntimeClass exists with correct handler
HANDLER=$(kubectl get runtimeclass sandboxed -o jsonpath='{.handler}' 2>/dev/null)
if [ "$HANDLER" = "runsc" ]; then
  echo "[PASS] RuntimeClass 'sandboxed' exists with handler 'runsc'"
else
  echo "[FAIL] RuntimeClass 'sandboxed' not found or handler is not 'runsc' (got: '$HANDLER')"
  PASS=false
fi

# Check each deployment has runtimeClassName: sandboxed
for DEPLOY in workload1 workload2 workload3; do
  RC=$(kubectl get deploy "$DEPLOY" -n server -o jsonpath='{.spec.template.spec.runtimeClassName}' 2>/dev/null)
  if [ "$RC" = "sandboxed" ]; then
    echo "[PASS] Deployment $DEPLOY has runtimeClassName: sandboxed"
  else
    echo "[FAIL] Deployment $DEPLOY runtimeClassName is '$RC' (expected: sandboxed)"
    PASS=false
  fi
done

# Note: pods may be Pending if runsc is not installed — we check the spec, not pod status
echo ""
echo "Note: Pods may be Pending if runsc/gVisor is not installed on the node."
echo "      The verify checks the deployment spec, not pod status."

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
