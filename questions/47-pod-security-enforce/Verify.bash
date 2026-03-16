#!/bin/bash
set -uo pipefail
echo "=== Verify: Pod Security Enforce ==="
PASS=true

# Check 1: Namespace team-blue has the restricted enforcement label
LABEL=$(kubectl get ns team-blue -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}' 2>/dev/null)
if [ "$LABEL" = "restricted" ]; then
  echo "[PASS] Namespace team-blue has pod-security.kubernetes.io/enforce=restricted"
else
  echo "[FAIL] Namespace team-blue missing enforce=restricted label (got: '$LABEL')"
  PASS=false
fi

# Check 2: /opt/candidate/16/logs exists
if [ -f /opt/candidate/16/logs ]; then
  echo "[PASS] /opt/candidate/16/logs exists"
else
  echo "[FAIL] /opt/candidate/16/logs not found"
  PASS=false
fi

# Check 3: logs file is non-empty
if [ -s /opt/candidate/16/logs ]; then
  echo "[PASS] logs file is non-empty"
else
  echo "[FAIL] logs file is empty"
  PASS=false
fi

# Check 4: logs contain evidence of FailedCreate / forbidden / violation
if grep -qi -e "FailedCreate" -e "forbidden" -e "violat" /opt/candidate/16/logs 2>/dev/null; then
  echo "[PASS] logs contain Pod Security violation evidence"
else
  echo "[FAIL] logs do not contain FailedCreate/forbidden/violation keywords"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
