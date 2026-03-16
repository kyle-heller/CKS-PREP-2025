#!/bin/bash
echo "=== Verify: API Server Security ==="
PASS=true

MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"

if grep -q 'authorization-mode=Node,RBAC' "$MANIFEST"; then
  echo "[PASS] Authorization mode is Node,RBAC"
else
  echo "[FAIL] Authorization mode is not Node,RBAC"
  PASS=false
fi

if grep -q 'anonymous-auth=false' "$MANIFEST"; then
  echo "[PASS] Anonymous auth is disabled"
else
  echo "[FAIL] Anonymous auth is not disabled"
  PASS=false
fi

if grep -q 'NodeRestriction' "$MANIFEST"; then
  echo "[PASS] NodeRestriction admission plugin enabled"
else
  echo "[FAIL] NodeRestriction not found"
  PASS=false
fi

if ! kubectl get clusterrolebinding system:anonymous &>/dev/null; then
  echo "[PASS] Anonymous ClusterRoleBinding removed"
else
  echo "[FAIL] Anonymous ClusterRoleBinding still exists"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
