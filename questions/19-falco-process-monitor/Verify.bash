#!/bin/bash
echo "=== Verify: Falco Process Monitoring ==="
PASS=true

RULE_FILE="/home/candidate/falco-rule.yaml"
FALCO_CONFIG="/etc/falco/falco.yaml"

# Check 1: Rule file has proper Falco rule structure
if [ -f "$RULE_FILE" ]; then
  echo "[PASS] Rule file exists at $RULE_FILE"
else
  echo "[FAIL] Rule file not found at $RULE_FILE"
  PASS=false
fi

# Check 2: Rule has evt.type condition (process execution detection)
if grep -q 'evt.type' "$RULE_FILE" 2>/dev/null; then
  echo "[PASS] Rule has evt.type condition"
else
  echo "[FAIL] Rule missing evt.type in condition"
  PASS=false
fi

# Check 3: Rule filters for container events
if grep -q 'container' "$RULE_FILE" 2>/dev/null; then
  echo "[PASS] Rule filters for container context"
else
  echo "[FAIL] Rule missing container filter in condition"
  PASS=false
fi

# Check 4: Output includes process name
if grep -q 'proc.name\|proc\.name' "$RULE_FILE" 2>/dev/null; then
  echo "[PASS] Rule output includes proc.name"
else
  echo "[FAIL] Rule output missing proc.name"
  PASS=false
fi

# Check 5: Falco config has file_output pointing to correct path
# Note: must anchor to ^file_output: to avoid matching comments that mention file_output
# and use -A10 because Falco's default config has ~7 comment lines between key and filename
if [ -f "$FALCO_CONFIG" ]; then
  if grep -A10 '^file_output:' "$FALCO_CONFIG" 2>/dev/null | grep -q 'enabled: true'; then
    echo "[PASS] falco.yaml file_output is enabled"
  else
    echo "[FAIL] falco.yaml file_output not enabled"
    PASS=false
  fi

  if grep -A10 '^file_output:' "$FALCO_CONFIG" 2>/dev/null | grep -q '/opt/falco-alerts/details'; then
    echo "[PASS] file_output filename points to /opt/falco-alerts/details"
  else
    echo "[FAIL] file_output filename not set to /opt/falco-alerts/details"
    PASS=false
  fi
else
  echo "[FAIL] /etc/falco/falco.yaml not found (Falco not installed)"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
