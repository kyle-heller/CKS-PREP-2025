#!/bin/bash
echo "=== Verify: NetworkPolicy Allow Port 80 ==="
PASS=true

# Check 1: NetworkPolicy allow-np exists in staging
NP=$(kubectl get netpol allow-np -n staging -o jsonpath='{.metadata.name}' 2>/dev/null)
if [ "$NP" = "allow-np" ]; then
  echo "[PASS] NetworkPolicy allow-np exists in staging"
else
  echo "[FAIL] NetworkPolicy allow-np not found in staging"
  PASS=false
fi

# Check 2: podSelector is empty (applies to all pods)
SEL=$(kubectl get netpol allow-np -n staging -o jsonpath='{.spec.podSelector}' 2>/dev/null)
if [ "$SEL" = "{}" ]; then
  echo "[PASS] podSelector is empty (applies to all pods)"
else
  echo "[FAIL] podSelector should be empty, got: $SEL"
  PASS=false
fi

# Check 3: policyTypes includes Ingress
TYPES=$(kubectl get netpol allow-np -n staging -o jsonpath='{.spec.policyTypes[*]}' 2>/dev/null)
if echo "$TYPES" | grep -q "Ingress"; then
  echo "[PASS] policyTypes includes Ingress"
else
  echo "[FAIL] policyTypes: $TYPES (need Ingress)"
  PASS=false
fi

# Check 4: Ingress rule has port 80
PORT=$(kubectl get netpol allow-np -n staging -o jsonpath='{.spec.ingress[0].ports[0].port}' 2>/dev/null)
if [ "$PORT" = "80" ]; then
  echo "[PASS] Ingress rule allows port 80"
else
  echo "[FAIL] Ingress port: $PORT (expected 80)"
  PASS=false
fi

# Check 5: Ingress rule has protocol TCP
PROTO=$(kubectl get netpol allow-np -n staging -o jsonpath='{.spec.ingress[0].ports[0].protocol}' 2>/dev/null)
if [ "$PROTO" = "TCP" ] || [ -z "$PROTO" ]; then
  echo "[PASS] Ingress protocol is TCP (default)"
else
  echo "[FAIL] Ingress protocol: $PROTO (expected TCP)"
  PASS=false
fi

# Check 6: Ingress from clause uses podSelector (same namespace)
FROM_SEL=$(kubectl get netpol allow-np -n staging -o jsonpath='{.spec.ingress[0].from[0].podSelector}' 2>/dev/null)
if [ "$FROM_SEL" = "{}" ]; then
  echo "[PASS] Ingress from podSelector: {} (same namespace pods)"
else
  echo "[FAIL] Ingress from podSelector: $FROM_SEL (expected {})"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
