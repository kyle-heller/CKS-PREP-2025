#!/bin/bash
echo "=== Verify: Falco /dev/mem Detection ==="
echo "(Note: Actual Falco runtime test skipped — validating rule file + deployment state)"
echo ""
PASS=true

RULE_FILE="/home/candidate/falco-rule.yaml"

# Check rule file exists
if [ ! -f "$RULE_FILE" ]; then
  echo "[FAIL] Rule file not found at $RULE_FILE"
  exit 1
fi

RULE_CONTENT=$(cat "$RULE_FILE")

# Check rule contains the key condition elements
if echo "$RULE_CONTENT" | grep -q 'evt.is_open_read'; then
  echo "[PASS] Rule contains evt.is_open_read"
else
  echo "[FAIL] Rule missing evt.is_open_read condition"
  PASS=false
fi

if echo "$RULE_CONTENT" | grep -q '/dev/mem'; then
  echo "[PASS] Rule references /dev/mem"
else
  echo "[FAIL] Rule missing /dev/mem reference"
  PASS=false
fi

if echo "$RULE_CONTENT" | grep -q 'fd.name'; then
  echo "[PASS] Rule uses fd.name for file path matching"
else
  echo "[FAIL] Rule missing fd.name (needed to match file path)"
  PASS=false
fi

# Check output fields
if echo "$RULE_CONTENT" | grep -q 'k8s.pod.name'; then
  echo "[PASS] Rule output includes pod name"
else
  echo "[FAIL] Rule output missing k8s.pod.name"
  PASS=false
fi

# Check deployment is scaled to 0
REPLICAS=$(kubectl get deploy mem-hacker -n default -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$REPLICAS" = "0" ]; then
  echo "[PASS] Deployment mem-hacker scaled to 0 replicas"
else
  echo "[FAIL] Deployment mem-hacker has $REPLICAS replicas (expected: 0)"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
