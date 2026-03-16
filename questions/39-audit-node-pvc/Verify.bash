#!/bin/bash
echo "=== Verify: Audit Node and PVC Changes ==="
echo ""
PASS=true

POLICY="/etc/audit/audit-policy.yaml"
MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"

# ---- Audit Policy Checks ----

# Check 1: Audit policy file exists
if [ ! -f "$POLICY" ]; then
  echo "[FAIL] Audit policy not found at $POLICY"
  PASS=false
else
  echo "[PASS] Audit policy exists at $POLICY"
fi

POLICY_CONTENT=$(cat "$POLICY" 2>/dev/null || echo "")

# Check 2: Policy has RequestResponse level for nodes
if echo "$POLICY_CONTENT" | grep -q 'RequestResponse' && echo "$POLICY_CONTENT" | grep -q 'nodes'; then
  echo "[PASS] Policy contains RequestResponse level and nodes resource"
else
  echo "[FAIL] Policy missing RequestResponse level for nodes"
  echo "  Hint: Add a rule with level: RequestResponse for resources: [\"nodes\"]"
  PASS=false
fi

# Check 3: Policy has Request level for PVCs in frontend namespace
if echo "$POLICY_CONTENT" | grep -q 'Request' && \
   echo "$POLICY_CONTENT" | grep -q 'persistentvolumeclaims' && \
   echo "$POLICY_CONTENT" | grep -q 'frontend'; then
  echo "[PASS] Policy contains Request level for PVCs in frontend namespace"
else
  echo "[FAIL] Policy missing Request level for persistentvolumeclaims in frontend namespace"
  echo "  Hint: Add a rule with level: Request, resources: [\"persistentvolumeclaims\"], namespaces: [\"frontend\"]"
  PASS=false
fi

# ---- API Server Manifest Checks ----

if [ ! -f "$MANIFEST" ]; then
  echo "[FAIL] API server manifest not found at $MANIFEST"
  echo "  (This check requires running on a control-plane node)"
  PASS=false
else
  MANIFEST_CONTENT=$(cat "$MANIFEST")

  # Check 4: --audit-policy-file flag
  if echo "$MANIFEST_CONTENT" | grep -q 'audit-policy-file'; then
    echo "[PASS] API server has --audit-policy-file flag"
  else
    echo "[FAIL] API server missing --audit-policy-file flag"
    PASS=false
  fi

  # Check 5: --audit-log-path
  if echo "$MANIFEST_CONTENT" | grep -q 'audit-log-path=/var/log/kubernetes-logs.log'; then
    echo "[PASS] Audit log path set to /var/log/kubernetes-logs.log"
  else
    echo "[FAIL] Audit log path not set to /var/log/kubernetes-logs.log"
    PASS=false
  fi

  # Check 6: --audit-log-maxage=5
  if echo "$MANIFEST_CONTENT" | grep -q 'audit-log-maxage=5'; then
    echo "[PASS] Log retention set to 5 days"
  else
    echo "[FAIL] Log retention (--audit-log-maxage) not set to 5"
    PASS=false
  fi

  # Check 7: --audit-log-maxbackup=10
  if echo "$MANIFEST_CONTENT" | grep -q 'audit-log-maxbackup=10'; then
    echo "[PASS] Max backup files set to 10"
  else
    echo "[FAIL] Max backup (--audit-log-maxbackup) not set to 10"
    PASS=false
  fi
fi

echo ""
$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
