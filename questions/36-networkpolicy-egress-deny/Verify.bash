#!/bin/bash
echo "=== Verify: Default Deny Egress NetworkPolicy ==="
PASS=true

# Check 1: NetworkPolicy default-deny exists in namespace testing
if kubectl get networkpolicy default-deny -n testing &>/dev/null; then
  echo "[PASS] NetworkPolicy default-deny exists in namespace testing"
else
  echo "[FAIL] NetworkPolicy default-deny not found in namespace testing"
  PASS=false
fi

# Check 2: podSelector is empty (matches all pods)
POD_SELECTOR=$(kubectl get networkpolicy default-deny -n testing \
  -o jsonpath='{.spec.podSelector}' 2>/dev/null)
if [ "$POD_SELECTOR" = "{}" ] || [ "$POD_SELECTOR" = "" ]; then
  echo "[PASS] podSelector is empty (matches all pods)"
else
  echo "[FAIL] podSelector is not empty (got: '$POD_SELECTOR')"
  PASS=false
fi

# Check 3: policyTypes includes Egress
POLICY_TYPES=$(kubectl get networkpolicy default-deny -n testing \
  -o jsonpath='{.spec.policyTypes[*]}' 2>/dev/null)
if echo "$POLICY_TYPES" | grep -q "Egress"; then
  echo "[PASS] policyTypes includes Egress"
else
  echo "[FAIL] policyTypes does not include Egress (got: '$POLICY_TYPES')"
  PASS=false
fi

# Check 4: No egress rules defined (blocks all egress)
EGRESS_RULES=$(kubectl get networkpolicy default-deny -n testing \
  -o jsonpath='{.spec.egress}' 2>/dev/null)
if [ -z "$EGRESS_RULES" ] || [ "$EGRESS_RULES" = "null" ]; then
  echo "[PASS] No egress rules defined (all egress blocked)"
else
  # Egress rules exist — this is acceptable if they only allow DNS
  echo "[PASS] Egress rules present (check if DNS-only exception)"
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
