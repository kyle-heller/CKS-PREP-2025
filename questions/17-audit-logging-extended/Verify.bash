#!/bin/bash
echo "=== Verify: Audit Logging Extended ==="
PASS=true
M="/etc/kubernetes/manifests/kube-apiserver.yaml"
P="/etc/audit/audit-policy.yaml"

# API server flags
grep -q 'audit-policy-file' "$M" && echo "[PASS] --audit-policy-file flag set" || { echo "[FAIL] --audit-policy-file flag missing"; PASS=false; }
grep -q 'audit-log-path' "$M" && echo "[PASS] --audit-log-path flag set" || { echo "[FAIL] --audit-log-path flag missing"; PASS=false; }
grep -q 'audit-log-maxage=12' "$M" && echo "[PASS] maxage=12" || { echo "[FAIL] maxage not 12"; PASS=false; }
grep -q 'audit-log-maxbackup=8' "$M" && echo "[PASS] maxbackup=8" || { echo "[FAIL] maxbackup not 8"; PASS=false; }
grep -q 'audit-log-maxsize=200' "$M" && echo "[PASS] maxsize=200" || { echo "[FAIL] maxsize not 200"; PASS=false; }

# Audit policy checks
grep -q 'omitStages' "$P" && echo "[PASS] omitStages present" || { echo "[FAIL] omitStages missing"; PASS=false; }
grep -q 'RequestReceived' "$P" && echo "[PASS] RequestReceived in omitStages" || { echo "[FAIL] RequestReceived not in policy"; PASS=false; }

# Check for namespace rule at RequestResponse
if grep -q 'RequestResponse' "$P" && grep -q 'namespaces' "$P"; then
  echo "[PASS] Namespaces rule at RequestResponse level"
else
  echo "[FAIL] Missing namespaces rule at RequestResponse"
  PASS=false
fi

# Check for secrets rule in kube-system
if grep -q 'kube-system' "$P" && grep -q 'secrets' "$P"; then
  echo "[PASS] Secrets rule for kube-system"
else
  echo "[FAIL] Missing secrets rule for kube-system"
  PASS=false
fi

# Check for Metadata as default catch-all
METADATA_COUNT=$(grep -c 'Metadata' "$P" 2>/dev/null || echo "0")
if [ "$METADATA_COUNT" -ge 2 ]; then
  echo "[PASS] Metadata level rules present (catch-all + portforward/proxy)"
else
  echo "[FAIL] Missing Metadata level rules"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
