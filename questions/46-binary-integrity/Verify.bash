#!/bin/bash
set -uo pipefail
echo "=== Verify: Binary Integrity ==="
PASS=true

# Check 1: kube-apiserver still exists (correct checksum)
if [ -f /opt/candidate/15/binaries/kube-apiserver ]; then
  echo "[PASS] kube-apiserver still exists (valid binary kept)"
else
  echo "[FAIL] kube-apiserver was deleted -- it had a valid checksum"
  PASS=false
fi

# Check 2: kube-proxy still exists (correct checksum)
if [ -f /opt/candidate/15/binaries/kube-proxy ]; then
  echo "[PASS] kube-proxy still exists (valid binary kept)"
else
  echo "[FAIL] kube-proxy was deleted -- it had a valid checksum"
  PASS=false
fi

# Check 3: kube-controller-manager deleted (wrong checksum)
if [ ! -f /opt/candidate/15/binaries/kube-controller-manager ]; then
  echo "[PASS] kube-controller-manager deleted (invalid checksum)"
else
  echo "[FAIL] kube-controller-manager still exists -- checksum was wrong, should be deleted"
  PASS=false
fi

# Check 4: kubelet deleted (wrong checksum)
if [ ! -f /opt/candidate/15/binaries/kubelet ]; then
  echo "[PASS] kubelet deleted (invalid checksum)"
else
  echo "[FAIL] kubelet still exists -- checksum was wrong, should be deleted"
  PASS=false
fi

# Check 5: Exactly 2 files remain
FILE_COUNT=$(ls -1 /opt/candidate/15/binaries/ 2>/dev/null | wc -l)
if [ "$FILE_COUNT" -eq 2 ]; then
  echo "[PASS] Exactly 2 binaries remain in directory"
else
  echo "[FAIL] Expected 2 files, found $FILE_COUNT"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
