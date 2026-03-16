#!/bin/bash
echo "=== Verify: Falco Monitor Pod ==="
echo "(Note: Falco runtime not tested — validating rule file structure)"
echo ""
PASS=true

RULE_FILE="/etc/falco/falco_rules.local.yaml"

# Check 1: Rule file exists
if [ ! -f "$RULE_FILE" ]; then
  echo "[FAIL] Rule file not found at $RULE_FILE"
  PASS=false
else
  echo "[PASS] Rule file exists at $RULE_FILE"
fi

RULE_CONTENT=$(cat "$RULE_FILE" 2>/dev/null || echo "")

# Check 2: Rule contains evt.type condition (e.g., execve or spawned_process)
if echo "$RULE_CONTENT" | grep -q 'evt.type'; then
  echo "[PASS] Rule contains evt.type condition"
else
  echo "[FAIL] Rule missing evt.type condition (e.g., evt.type = execve)"
  PASS=false
fi

# Check 3: Rule filters by container (container.name or container)
if echo "$RULE_CONTENT" | grep -q 'container'; then
  echo "[PASS] Rule contains container filter"
else
  echo "[FAIL] Rule missing container filter (should reference container.name = tomcat)"
  PASS=false
fi

# Check 4: Output format includes %evt.time
if echo "$RULE_CONTENT" | grep -q '%evt.time'; then
  echo "[PASS] Output format includes %evt.time"
else
  echo "[FAIL] Output format missing %evt.time"
  PASS=false
fi

# Check 5: Output format includes %user.uid
if echo "$RULE_CONTENT" | grep -q '%user.uid'; then
  echo "[PASS] Output format includes %user.uid"
else
  echo "[FAIL] Output format missing %user.uid"
  PASS=false
fi

# Check 6: Output format includes %proc.name
if echo "$RULE_CONTENT" | grep -q '%proc.name'; then
  echo "[PASS] Output format includes %proc.name"
else
  echo "[FAIL] Output format missing %proc.name"
  PASS=false
fi

# Check 7: Output directory exists
if [ -d /home/anomalous ]; then
  echo "[PASS] Output directory /home/anomalous/ exists"
else
  echo "[FAIL] Output directory /home/anomalous/ not found"
  PASS=false
fi

# Check 8: Rule has a priority field
if echo "$RULE_CONTENT" | grep -q 'priority:'; then
  echo "[PASS] Rule has priority field"
else
  echo "[FAIL] Rule missing priority field"
  PASS=false
fi

echo ""
$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
