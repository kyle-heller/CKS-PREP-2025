#!/bin/bash
echo "=== Verify: Dockerfile and Deployment Fixes (Kafka) ==="
PASS=true

DF="/home/manifests/Dockerfile"
DEP="/home/manifests/deployment.yaml"

# Check 1: Dockerfile does not use :latest
if ! grep -q 'ubuntu:latest' "$DF"; then
  echo "[PASS] Dockerfile no longer uses :latest"
else
  echo "[FAIL] Dockerfile still uses ubuntu:latest"
  PASS=false
fi

# Check 2: Dockerfile uses non-root user
if grep -qi 'USER nobody\|USER 65535' "$DF" && ! grep -qi 'USER root' "$DF"; then
  echo "[PASS] Dockerfile uses non-root user"
else
  echo "[FAIL] Dockerfile still runs as root"
  PASS=false
fi

# Check 3: Deployment runAsUser is 65535
if grep -q 'runAsUser: 65535' "$DEP"; then
  echo "[PASS] Deployment runAsUser is 65535"
else
  echo "[FAIL] Deployment runAsUser is not 65535"
  PASS=false
fi

# Check 4: Deployment privileged is false
if grep -q 'privileged: false' "$DEP"; then
  echo "[PASS] Deployment privileged is false"
else
  echo "[FAIL] Deployment still has privileged: true"
  PASS=false
fi

# Check 5: Deployment readOnlyRootFilesystem is true
if grep -q 'readOnlyRootFilesystem: true' "$DEP"; then
  echo "[PASS] Deployment readOnlyRootFilesystem is true"
else
  echo "[FAIL] Deployment readOnlyRootFilesystem is not true"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
