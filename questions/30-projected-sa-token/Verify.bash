#!/bin/bash
echo "=== Verify: Projected SA Token ==="
PASS=true

# Check 1: Default SA has automountServiceAccountToken: false
AUTOMOUNT=$(kubectl get sa default -o jsonpath='{.automountServiceAccountToken}' 2>/dev/null)
if [ "$AUTOMOUNT" = "false" ]; then
  echo "[PASS] Default SA has automountServiceAccountToken: false"
else
  echo "[FAIL] Default SA automountServiceAccountToken is '$AUTOMOUNT' (expected: false)"
  PASS=false
fi

# Check 2: Pod token-demo exists
if kubectl get pod token-demo &>/dev/null; then
  echo "[PASS] Pod token-demo exists"
else
  echo "[FAIL] Pod token-demo not found"
  PASS=false
fi

# Check 3: Pod has projected volume with serviceAccountToken
HAS_PROJECTED=$(kubectl get pod token-demo -o json 2>/dev/null | \
  python3 -c "
import json, sys
pod = json.load(sys.stdin)
for vol in pod.get('spec',{}).get('volumes',[]):
  proj = vol.get('projected',{})
  for src in proj.get('sources',[]):
    if 'serviceAccountToken' in src:
      print('found')
      sys.exit(0)
" 2>/dev/null)
if [ "$HAS_PROJECTED" = "found" ]; then
  echo "[PASS] Pod has projected volume with serviceAccountToken"
else
  echo "[FAIL] Pod missing projected serviceAccountToken volume"
  PASS=false
fi

# Check 4: Token path is token.jwt
TOKEN_PATH=$(kubectl get pod token-demo -o json 2>/dev/null | \
  python3 -c "
import json, sys
pod = json.load(sys.stdin)
for vol in pod.get('spec',{}).get('volumes',[]):
  proj = vol.get('projected',{})
  for src in proj.get('sources',[]):
    sat = src.get('serviceAccountToken',{})
    if sat.get('path'):
      print(sat['path'])
      sys.exit(0)
" 2>/dev/null)
if [ "$TOKEN_PATH" = "token.jwt" ]; then
  echo "[PASS] Token path is token.jwt"
else
  echo "[FAIL] Token path is '$TOKEN_PATH' (expected: token.jwt)"
  PASS=false
fi

# Check 5: expirationSeconds is set
EXPIRATION=$(kubectl get pod token-demo -o json 2>/dev/null | \
  python3 -c "
import json, sys
pod = json.load(sys.stdin)
for vol in pod.get('spec',{}).get('volumes',[]):
  proj = vol.get('projected',{})
  for src in proj.get('sources',[]):
    sat = src.get('serviceAccountToken',{})
    if sat.get('expirationSeconds'):
      print(sat['expirationSeconds'])
      sys.exit(0)
" 2>/dev/null)
if [ -n "$EXPIRATION" ] && [ "$EXPIRATION" -gt 0 ] 2>/dev/null; then
  echo "[PASS] expirationSeconds is set to $EXPIRATION"
else
  echo "[FAIL] expirationSeconds not set"
  PASS=false
fi

# Check 6: Volume mounted at /var/run/secrets/tokens
MOUNT_PATH=$(kubectl get pod token-demo -o jsonpath='{.spec.containers[0].volumeMounts}' 2>/dev/null | \
  python3 -c "
import json, sys
mounts = json.load(sys.stdin)
for m in mounts:
  if '/var/run/secrets/tokens' in m.get('mountPath',''):
    print(m['mountPath'])
    sys.exit(0)
" 2>/dev/null)
if [ -n "$MOUNT_PATH" ]; then
  echo "[PASS] Volume mounted at $MOUNT_PATH"
else
  echo "[FAIL] No volume mount at /var/run/secrets/tokens"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
