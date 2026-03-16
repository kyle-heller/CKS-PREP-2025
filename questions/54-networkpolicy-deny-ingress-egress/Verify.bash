#!/bin/bash
echo "=== Verify: NetworkPolicy Deny All Ingress+Egress ==="
PASS=true

# Check 1: NetworkPolicy deny-network exists in test namespace
NP=$(kubectl get netpol deny-network -n test -o jsonpath='{.metadata.name}' 2>/dev/null)
if [ "$NP" = "deny-network" ]; then
  echo "[PASS] NetworkPolicy deny-network exists in test"
else
  echo "[FAIL] NetworkPolicy deny-network not found in test"
  PASS=false
fi

# Check 2: podSelector is empty (applies to all pods)
SEL=$(kubectl get netpol deny-network -n test -o jsonpath='{.spec.podSelector}' 2>/dev/null)
if [ "$SEL" = "{}" ]; then
  echo "[PASS] podSelector is empty (applies to all pods)"
else
  echo "[FAIL] podSelector should be empty, got: $SEL"
  PASS=false
fi

# Check 3: policyTypes includes both Ingress and Egress
TYPES=$(kubectl get netpol deny-network -n test -o jsonpath='{.spec.policyTypes[*]}' 2>/dev/null)
if echo "$TYPES" | grep -q "Ingress" && echo "$TYPES" | grep -q "Egress"; then
  echo "[PASS] policyTypes includes both Ingress and Egress"
else
  echo "[FAIL] policyTypes: $TYPES (need both Ingress and Egress)"
  PASS=false
fi

# Check 4: No ingress rules (deny all ingress)
INGRESS=$(kubectl get netpol deny-network -n test -o jsonpath='{.spec.ingress}' 2>/dev/null)
if [ -z "$INGRESS" ] || [ "$INGRESS" = "null" ]; then
  echo "[PASS] No ingress rules (all ingress denied)"
else
  echo "[FAIL] Ingress rules found — should be empty to deny all"
  PASS=false
fi

# Check 5: No egress rules (deny all egress)
EGRESS=$(kubectl get netpol deny-network -n test -o jsonpath='{.spec.egress}' 2>/dev/null)
if [ -z "$EGRESS" ] || [ "$EGRESS" = "null" ]; then
  echo "[PASS] No egress rules (all egress denied)"
else
  echo "[FAIL] Egress rules found — should be empty to deny all"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
