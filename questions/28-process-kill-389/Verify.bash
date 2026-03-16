#!/bin/bash
echo "=== Verify: Process Kill 389 ==="
PASS=true

# Check 1: Nothing listening on port 389
if command -v ss &>/dev/null; then
  LISTENING=$(ss -tlnp 'sport = :389' 2>/dev/null | grep -c ':389' || true)
elif command -v netstat &>/dev/null; then
  LISTENING=$(netstat -tlnp 2>/dev/null | grep -c ':389 ' || true)
else
  LISTENING=0
fi

if [ "${LISTENING:-0}" -eq 0 ]; then
  echo "[PASS] No process listening on port 389"
else
  echo "[FAIL] Process still listening on port 389"
  PASS=false
fi

# Check 2: files.txt exists and is non-empty
if [ -f /candidate/13/files.txt ]; then
  echo "[PASS] /candidate/13/files.txt exists"
else
  echo "[FAIL] /candidate/13/files.txt not found"
  PASS=false
fi

if [ -s /candidate/13/files.txt ]; then
  echo "[PASS] files.txt is non-empty"
else
  echo "[FAIL] files.txt is empty"
  PASS=false
fi

# Check 3: fake-ldap binary has been deleted
if [ ! -f /usr/local/bin/fake-ldap ]; then
  echo "[PASS] /usr/local/bin/fake-ldap binary deleted"
else
  echo "[FAIL] /usr/local/bin/fake-ldap still exists"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
