#!/bin/bash
echo "=== Verify: Dockerfile and Pod Fixes ==="
PASS=true

DF="/home/candidate/06/Dockerfile"
POD="/home/candidate/06/pod.yaml"

if ! grep -q 'ubuntu:latest' "$DF"; then
  echo "[PASS] Dockerfile no longer uses :latest"
else
  echo "[FAIL] Dockerfile still uses ubuntu:latest"
  PASS=false
fi

if grep -qi 'USER test-user\|USER 5375\|USER nobody' "$DF" && ! grep -qi 'USER ROOT' "$DF"; then
  echo "[PASS] Dockerfile uses non-root user"
else
  echo "[FAIL] Dockerfile still runs as ROOT"
  PASS=false
fi

if grep -q 'runAsUser: 5375' "$POD"; then
  echo "[PASS] Pod uses runAsUser 5375"
else
  echo "[FAIL] Pod runAsUser not set to 5375"
  PASS=false
fi

if grep -q 'privileged: false' "$POD"; then
  echo "[PASS] Pod privileged is false"
else
  echo "[FAIL] Pod still has privileged: true"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
