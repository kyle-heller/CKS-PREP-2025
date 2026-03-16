#!/bin/bash
echo "=== Verify: Seccomp Profile ==="
PASS=true

PROFILE="/var/lib/kubelet/seccomp/profiles/seccomp-profile.json"

# Check 1: Seccomp profile file exists
if [ -f "$PROFILE" ]; then
  echo "[PASS] Seccomp profile exists at $PROFILE"
else
  echo "[FAIL] Seccomp profile not found at $PROFILE"
  PASS=false
fi

# Check 2: Profile has SCMP_ACT_ERRNO as defaultAction
if grep -q 'SCMP_ACT_ERRNO' "$PROFILE" 2>/dev/null; then
  echo "[PASS] Profile defaultAction is SCMP_ACT_ERRNO"
else
  echo "[FAIL] Profile missing SCMP_ACT_ERRNO defaultAction"
  PASS=false
fi

# Check 3: Profile allows read, write, exit, sigreturn
for SYSCALL in read write exit sigreturn; do
  if grep -q "\"$SYSCALL\"" "$PROFILE" 2>/dev/null; then
    echo "[PASS] Profile allows syscall: $SYSCALL"
  else
    echo "[FAIL] Profile missing allowed syscall: $SYSCALL"
    PASS=false
  fi
done

# Check 4: Deployment has seccompProfile type Localhost
SECCOMP_TYPE=$(kubectl get deployment webapp -n secure-app \
  -o jsonpath='{.spec.template.spec.securityContext.seccompProfile.type}' 2>/dev/null)
if [ -z "$SECCOMP_TYPE" ]; then
  # Check container-level seccomp
  SECCOMP_TYPE=$(kubectl get deployment webapp -n secure-app \
    -o jsonpath='{.spec.template.spec.containers[0].securityContext.seccompProfile.type}' 2>/dev/null)
fi

if [ "$SECCOMP_TYPE" = "Localhost" ]; then
  echo "[PASS] Deployment webapp has seccompProfile type: Localhost"
else
  echo "[FAIL] Deployment webapp seccompProfile type not Localhost (got: '$SECCOMP_TYPE')"
  PASS=false
fi

# Check 5: localhostProfile references the correct file
PROFILE_REF=$(kubectl get deployment webapp -n secure-app \
  -o jsonpath='{.spec.template.spec.securityContext.seccompProfile.localhostProfile}' 2>/dev/null)
if [ -z "$PROFILE_REF" ]; then
  PROFILE_REF=$(kubectl get deployment webapp -n secure-app \
    -o jsonpath='{.spec.template.spec.containers[0].securityContext.seccompProfile.localhostProfile}' 2>/dev/null)
fi

if [ "$PROFILE_REF" = "profiles/seccomp-profile.json" ]; then
  echo "[PASS] localhostProfile references profiles/seccomp-profile.json"
else
  echo "[FAIL] localhostProfile incorrect (got: '$PROFILE_REF')"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
