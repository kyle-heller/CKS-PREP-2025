#!/bin/bash
echo "=== Verify: Audit Logging ==="
PASS=true

MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"

if grep -q 'audit-log-path=/var/log/kubernetes-logs.log' "$MANIFEST"; then
  echo "[PASS] Audit log path configured"
else
  echo "[FAIL] Audit log path not set"
  PASS=false
fi

if grep -q 'audit-log-maxage=5' "$MANIFEST"; then
  echo "[PASS] Log retention set to 5 days"
else
  echo "[FAIL] Log retention not set to 5"
  PASS=false
fi

if grep -q 'audit-log-maxbackup=10' "$MANIFEST"; then
  echo "[PASS] Max backup files set to 10"
else
  echo "[FAIL] Max backup not set to 10"
  PASS=false
fi

if [ -f /etc/audit/audit-policy.yaml ]; then
  if grep -q 'RequestResponse' /etc/audit/audit-policy.yaml && \
     grep -q 'cronjobs' /etc/audit/audit-policy.yaml; then
    echo "[PASS] Audit policy has CronJob rule"
  else
    echo "[FAIL] Audit policy missing CronJob RequestResponse rule"
    PASS=false
  fi
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
