#!/bin/bash
echo "=== Verify: TLS Ingress ==="
PASS=true

# Check 1: TLS Secret exists with correct type
SECRET_TYPE=$(kubectl get secret bingo-tls -n testing -o jsonpath='{.type}' 2>/dev/null)
if [ "$SECRET_TYPE" = "kubernetes.io/tls" ]; then
  echo "[PASS] Secret bingo-tls exists with type kubernetes.io/tls"
else
  echo "[FAIL] Secret bingo-tls not found or wrong type (got: '$SECRET_TYPE')"
  PASS=false
fi

# Check 2: nginx-pod exists in testing namespace
if kubectl get pod nginx-pod -n testing &>/dev/null; then
  echo "[PASS] Pod nginx-pod exists in testing namespace"
else
  echo "[FAIL] Pod nginx-pod not found in testing namespace"
  PASS=false
fi

# Check 3: Service nginx-pod exists
if kubectl get service nginx-pod -n testing &>/dev/null; then
  echo "[PASS] Service nginx-pod exists in testing namespace"
else
  echo "[FAIL] Service nginx-pod not found in testing namespace"
  PASS=false
fi

# Check 4: Ingress bingo-com exists
if kubectl get ingress bingo-com -n testing &>/dev/null; then
  echo "[PASS] Ingress bingo-com exists in testing namespace"
else
  echo "[FAIL] Ingress bingo-com not found in testing namespace"
  PASS=false
fi

# Check 5: Ingress has correct host
ING_HOST=$(kubectl get ingress bingo-com -n testing -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
if [ "$ING_HOST" = "bingo.com" ]; then
  echo "[PASS] Ingress host is bingo.com"
else
  echo "[FAIL] Ingress host is '$ING_HOST' (expected: bingo.com)"
  PASS=false
fi

# Check 6: Ingress has TLS config with bingo-tls secret
TLS_SECRET=$(kubectl get ingress bingo-com -n testing -o jsonpath='{.spec.tls[0].secretName}' 2>/dev/null)
if [ "$TLS_SECRET" = "bingo-tls" ]; then
  echo "[PASS] Ingress TLS uses secret bingo-tls"
else
  echo "[FAIL] Ingress TLS secret is '$TLS_SECRET' (expected: bingo-tls)"
  PASS=false
fi

# Check 7: TLS hosts includes bingo.com
TLS_HOST=$(kubectl get ingress bingo-com -n testing -o jsonpath='{.spec.tls[0].hosts[0]}' 2>/dev/null)
if [ "$TLS_HOST" = "bingo.com" ]; then
  echo "[PASS] TLS hosts includes bingo.com"
else
  echo "[FAIL] TLS host is '$TLS_HOST' (expected: bingo.com)"
  PASS=false
fi

# Check 8: SSL redirect annotation
REDIRECT=$(kubectl get ingress bingo-com -n testing -o jsonpath='{.metadata.annotations.nginx\.ingress\.kubernetes\.io/ssl-redirect}' 2>/dev/null)
FORCE_REDIRECT=$(kubectl get ingress bingo-com -n testing -o jsonpath='{.metadata.annotations.nginx\.ingress\.kubernetes\.io/force-ssl-redirect}' 2>/dev/null)
if [ "$REDIRECT" = "true" ] || [ "$FORCE_REDIRECT" = "true" ]; then
  echo "[PASS] HTTP to HTTPS redirect annotation present"
else
  echo "[FAIL] No SSL redirect annotation found"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
