#!/bin/bash
echo "=== Verify: Istio mTLS ==="
echo "(Note: Istio not installed — validating manifest correctness only)"
echo ""
PASS=true

# Check namespace has istio-injection label
INJECTION=$(kubectl get ns payments -o jsonpath='{.metadata.labels.istio-injection}' 2>/dev/null)
if [ "$INJECTION" = "enabled" ]; then
  echo "[PASS] Namespace payments has label istio-injection=enabled"
else
  echo "[FAIL] Namespace payments missing istio-injection=enabled label (got: '$INJECTION')"
  PASS=false
fi

# Check PeerAuthentication exists with correct name
PA_NAME=$(kubectl get peerauthentication payments-mtls-strict -n payments -o jsonpath='{.metadata.name}' 2>/dev/null)
if [ "$PA_NAME" = "payments-mtls-strict" ]; then
  echo "[PASS] PeerAuthentication 'payments-mtls-strict' exists in payments namespace"
else
  echo "[FAIL] PeerAuthentication 'payments-mtls-strict' not found in payments namespace"
  PASS=false
fi

# Check mTLS mode is STRICT
MTLS_MODE=$(kubectl get peerauthentication payments-mtls-strict -n payments -o jsonpath='{.spec.mtls.mode}' 2>/dev/null)
if [ "$MTLS_MODE" = "STRICT" ]; then
  echo "[PASS] mTLS mode is STRICT"
else
  echo "[FAIL] mTLS mode is '$MTLS_MODE' (expected: STRICT)"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
