#!/bin/bash
echo "=== Verify: CIS Benchmark Fixes ==="
PASS=true

MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"
ETCD_MANIFEST="/etc/kubernetes/manifests/etcd.yaml"
KUBELET_CONFIG="/var/lib/kubelet/config.yaml"

# --- API Server checks ---
AUTH_MODE=$(grep '\-\-authorization-mode' "$MANIFEST" | head -1)
if echo "$AUTH_MODE" | grep -q 'Node' && echo "$AUTH_MODE" | grep -q 'RBAC'; then
  echo "[PASS] API server authorization-mode includes Node,RBAC"
else
  echo "[FAIL] API server authorization-mode missing Node or RBAC (got: $AUTH_MODE)"
  PASS=false
fi

# --- Kubelet checks ---
ANON_ENABLED=$(python3 -c "
import yaml, sys
with open('$KUBELET_CONFIG') as f:
    cfg = yaml.safe_load(f)
try:
    print(cfg['authentication']['anonymous']['enabled'])
except (KeyError, TypeError):
    print('MISSING')
" 2>/dev/null || echo "ERROR")

if [ "$ANON_ENABLED" = "False" ]; then
  echo "[PASS] Kubelet anonymous auth disabled"
else
  echo "[FAIL] Kubelet anonymous auth is '$ANON_ENABLED' (expected: False)"
  PASS=false
fi

AUTH_WEBHOOK=$(python3 -c "
import yaml, sys
with open('$KUBELET_CONFIG') as f:
    cfg = yaml.safe_load(f)
try:
    print(cfg['authorization']['mode'])
except (KeyError, TypeError):
    print('MISSING')
" 2>/dev/null || echo "ERROR")

if [ "$AUTH_WEBHOOK" = "Webhook" ]; then
  echo "[PASS] Kubelet authorization mode is Webhook"
else
  echo "[FAIL] Kubelet authorization mode is '$AUTH_WEBHOOK' (expected: Webhook)"
  PASS=false
fi

# --- ETCD checks ---
if grep -q '\-\-client-cert-auth=true' "$ETCD_MANIFEST"; then
  echo "[PASS] etcd has --client-cert-auth=true"
else
  echo "[FAIL] etcd missing --client-cert-auth=true"
  PASS=false
fi

if grep -q '\-\-auto-tls=true' "$ETCD_MANIFEST"; then
  echo "[FAIL] etcd still has --auto-tls=true"
  PASS=false
else
  echo "[PASS] etcd auto-tls not set to true"
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
