#!/bin/bash
echo "=== Verify: Audit Logging Extended ==="
PASS=true
M="/etc/kubernetes/manifests/kube-apiserver.yaml"
grep -q 'audit-log-maxage=12' "$M" && echo "[PASS] maxage=12" || { echo "[FAIL] maxage"; PASS=false; }
grep -q 'audit-log-maxbackup=8' "$M" && echo "[PASS] maxbackup=8" || { echo "[FAIL] maxbackup"; PASS=false; }
grep -q 'audit-log-maxsize=200' "$M" && echo "[PASS] maxsize=200" || { echo "[FAIL] maxsize"; PASS=false; }
grep -q 'omitStages' /etc/audit/audit-policy.yaml && echo "[PASS] omitStages present" || { echo "[FAIL] omitStages"; PASS=false; }
$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
