#!/bin/bash
echo "=== Verify: CiliumNetworkPolicy mTLS + ICMP ==="
PASS=true

# Check 1: CiliumNetworkPolicy team-dev exists
if kubectl get ciliumnetworkpolicy team-dev -n team-dev &>/dev/null 2>&1; then
  echo "[PASS] CiliumNetworkPolicy team-dev exists"
else
  echo "[FAIL] CiliumNetworkPolicy team-dev not found"
  PASS=false
fi

# Check 2: team-dev policy has endpointSelector for role=stuff
POLICY1=$(kubectl get ciliumnetworkpolicy team-dev -n team-dev -o json 2>/dev/null)
if echo "$POLICY1" | python3 -c "
import json, sys
p = json.load(sys.stdin)
spec = p.get('spec',{})
eps = spec.get('endpointSelector',{}).get('matchLabels',{})
if eps.get('role') == 'stuff':
    print('found')
" 2>/dev/null | grep -q "found"; then
  echo "[PASS] team-dev targets role=stuff"
else
  echo "[FAIL] team-dev does not target role=stuff"
  PASS=false
fi

# Check 3: team-dev has ICMP deny in egress
if echo "$POLICY1" | grep -qi 'icmp\|ICMP' 2>/dev/null; then
  echo "[PASS] team-dev contains ICMP rule"
else
  echo "[FAIL] team-dev missing ICMP rule"
  PASS=false
fi

# Check 4: CiliumNetworkPolicy team-dev-2 exists
if kubectl get ciliumnetworkpolicy team-dev-2 -n team-dev &>/dev/null 2>&1; then
  echo "[PASS] CiliumNetworkPolicy team-dev-2 exists"
else
  echo "[FAIL] CiliumNetworkPolicy team-dev-2 not found"
  PASS=false
fi

# Check 5: team-dev-2 has authentication/mutual auth config
POLICY2=$(kubectl get ciliumnetworkpolicy team-dev-2 -n team-dev -o json 2>/dev/null)
if echo "$POLICY2" | grep -qi 'authentication\|mutual' 2>/dev/null; then
  echo "[PASS] team-dev-2 contains authentication/mutual config"
else
  echo "[FAIL] team-dev-2 missing authentication/mutual config"
  PASS=false
fi

# Check 6: team-dev-2 references role=database or role=api-service
if echo "$POLICY2" | grep -q 'database\|api-service' 2>/dev/null; then
  echo "[PASS] team-dev-2 references database or api-service roles"
else
  echo "[FAIL] team-dev-2 missing database/api-service role references"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
