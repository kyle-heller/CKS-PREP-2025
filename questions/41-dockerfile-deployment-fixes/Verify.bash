#!/bin/bash
echo "=== Verify: Dockerfile and Deployment Fixes (Couchbase) ==="
echo ""
PASS=true

DF="/home/candidate/10/Dockerfile"
DEPLOY="/home/candidate/10/deployment.yaml"

# ---- Dockerfile Checks ----

if [ ! -f "$DF" ]; then
  echo "[FAIL] Dockerfile not found at $DF"
  PASS=false
else
  # Check 1: No :latest tag
  if grep -q 'ubuntu:latest' "$DF"; then
    echo "[FAIL] Dockerfile still uses ubuntu:latest — pin to a specific version"
    PASS=false
  else
    echo "[PASS] Dockerfile does not use :latest tag"
  fi

  # Check 2: Uses non-root user (nobody or UID 65535)
  if grep -qi 'USER nobody\|USER 65535' "$DF" && ! grep -qi 'USER root' "$DF"; then
    echo "[PASS] Dockerfile uses non-root user (nobody/65535)"
  else
    echo "[FAIL] Dockerfile does not use non-root user — expected USER nobody or USER 65535"
    PASS=false
  fi
fi

# ---- Deployment Manifest Checks ----

if [ ! -f "$DEPLOY" ]; then
  echo "[FAIL] Deployment manifest not found at $DEPLOY"
  PASS=false
else
  # Check 3: runAsUser is 65535 (not 0)
  if grep -q 'runAsUser: 65535' "$DEPLOY"; then
    echo "[PASS] Deployment uses runAsUser: 65535"
  else
    echo "[FAIL] Deployment runAsUser is not 65535"
    PASS=false
  fi

  # Check 4: privileged is false
  if grep -q 'privileged: false' "$DEPLOY"; then
    echo "[PASS] Deployment has privileged: false"
  else
    echo "[FAIL] Deployment still has privileged: true"
    PASS=false
  fi
fi

echo ""
$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
