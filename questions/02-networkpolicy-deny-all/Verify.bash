#!/bin/bash
echo "=== Verify: Default Deny NetworkPolicy ==="
PASS=true

NP=$(kubectl get netpol deny-all -n testing -o jsonpath='{.metadata.name}' 2>/dev/null)
if [ "$NP" = "deny-all" ]; then
  echo "[PASS] NetworkPolicy deny-all exists in testing"
else
  echo "[FAIL] NetworkPolicy deny-all not found in testing"
  PASS=false
fi

TYPES=$(kubectl get netpol deny-all -n testing -o jsonpath='{.spec.policyTypes[*]}' 2>/dev/null)
if echo "$TYPES" | grep -q "Ingress" && echo "$TYPES" | grep -q "Egress"; then
  echo "[PASS] Policy covers both Ingress and Egress"
else
  echo "[FAIL] Policy types: $TYPES (need both Ingress and Egress)"
  PASS=false
fi

SEL=$(kubectl get netpol deny-all -n testing -o jsonpath='{.spec.podSelector}' 2>/dev/null)
if [ "$SEL" = "{}" ]; then
  echo "[PASS] podSelector is empty (applies to all pods)"
else
  echo "[FAIL] podSelector should be empty, got: $SEL"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
