#!/bin/bash
echo "=== Verify: NetworkPolicy Restricted ==="
PASS=true

# Check 1: NetworkPolicy exists
if kubectl get networkpolicy restricted-policy -n dev-team &>/dev/null; then
  echo "[PASS] NetworkPolicy restricted-policy exists in dev-team"
else
  echo "[FAIL] NetworkPolicy restricted-policy not found in dev-team"
  PASS=false
fi

# Check 2: podSelector targets environment=dev
SELECTOR=$(kubectl get networkpolicy restricted-policy -n dev-team \
  -o jsonpath='{.spec.podSelector.matchLabels.environment}' 2>/dev/null)
if [ "$SELECTOR" = "dev" ]; then
  echo "[PASS] podSelector targets environment=dev"
else
  echo "[FAIL] podSelector does not target environment=dev (got: '$SELECTOR')"
  PASS=false
fi

# Check 3: policyTypes includes Ingress
POLICY_TYPES=$(kubectl get networkpolicy restricted-policy -n dev-team \
  -o jsonpath='{.spec.policyTypes[*]}' 2>/dev/null)
if echo "$POLICY_TYPES" | grep -q "Ingress"; then
  echo "[PASS] policyTypes includes Ingress"
else
  echo "[FAIL] policyTypes does not include Ingress (got: '$POLICY_TYPES')"
  PASS=false
fi

# Check 4: Has at least 2 ingress rules (same-ns + cross-ns)
RULE_COUNT=$(kubectl get networkpolicy restricted-policy -n dev-team \
  -o jsonpath='{.spec.ingress}' 2>/dev/null | python3 -c "import json,sys; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")
if [ "$RULE_COUNT" -ge 2 ] 2>/dev/null; then
  echo "[PASS] Has $RULE_COUNT ingress rules (expected >= 2)"
else
  echo "[FAIL] Expected >= 2 ingress rules (got: $RULE_COUNT)"
  PASS=false
fi

# Check 5: One rule allows from same namespace (podSelector: {})
SAME_NS=$(kubectl get networkpolicy restricted-policy -n dev-team -o json 2>/dev/null | \
  python3 -c "
import json, sys
pol = json.load(sys.stdin)
for rule in pol.get('spec',{}).get('ingress',[]):
  for fr in rule.get('from',[]):
    if 'podSelector' in fr and not fr['podSelector'].get('matchLabels') and 'namespaceSelector' not in fr:
      print('found')
      sys.exit(0)
" 2>/dev/null)
if [ "$SAME_NS" = "found" ]; then
  echo "[PASS] Ingress rule allows from same namespace (podSelector: {})"
else
  echo "[FAIL] No ingress rule for same-namespace pods (podSelector: {})"
  PASS=false
fi

# Check 6: One rule allows from pods with environment=testing in any namespace
CROSS_NS=$(kubectl get networkpolicy restricted-policy -n dev-team -o json 2>/dev/null | \
  python3 -c "
import json, sys
pol = json.load(sys.stdin)
for rule in pol.get('spec',{}).get('ingress',[]):
  for fr in rule.get('from',[]):
    ps = fr.get('podSelector',{}).get('matchLabels',{})
    if ps.get('environment') == 'testing' and 'namespaceSelector' in fr:
      print('found')
      sys.exit(0)
" 2>/dev/null)
if [ "$CROSS_NS" = "found" ]; then
  echo "[PASS] Ingress rule allows environment=testing from any namespace"
else
  echo "[FAIL] No cross-namespace ingress rule for environment=testing pods"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
