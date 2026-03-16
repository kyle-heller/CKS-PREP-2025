#!/bin/bash
echo "=== Verify: kube-bench Fixes ==="
PASS=true

MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"
ETCD_MANIFEST="/etc/kubernetes/manifests/etcd.yaml"
KUBELET_CONFIG="/var/lib/kubelet/config.yaml"

# --- API Server checks ---
if grep -q '\-\-kubelet-certificate-authority' "$MANIFEST"; then
  echo "[PASS] API server has --kubelet-certificate-authority"
else
  echo "[FAIL] API server missing --kubelet-certificate-authority"
  PASS=false
fi

if grep -q '\-\-profiling=true' "$MANIFEST"; then
  echo "[FAIL] API server still has --profiling=true"
  PASS=false
else
  echo "[PASS] API server profiling disabled (or removed)"
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

AUTH_MODE=$(python3 -c "
import yaml, sys
with open('$KUBELET_CONFIG') as f:
    cfg = yaml.safe_load(f)
try:
    print(cfg['authorization']['mode'])
except (KeyError, TypeError):
    print('MISSING')
" 2>/dev/null || echo "ERROR")

if [ "$AUTH_MODE" = "Webhook" ]; then
  echo "[PASS] Kubelet authorization mode is Webhook"
else
  echo "[FAIL] Kubelet authorization mode is '$AUTH_MODE' (expected: Webhook)"
  PASS=false
fi

# --- ETCD checks ---
if grep -q '\-\-auto-tls=true' "$ETCD_MANIFEST"; then
  echo "[FAIL] ETCD still has --auto-tls=true"
  PASS=false
else
  echo "[PASS] ETCD auto-tls not set to true"
fi

if grep -q '\-\-peer-auto-tls=true' "$ETCD_MANIFEST"; then
  echo "[FAIL] ETCD still has --peer-auto-tls=true"
  PASS=false
else
  echo "[PASS] ETCD peer-auto-tls not set to true"
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
