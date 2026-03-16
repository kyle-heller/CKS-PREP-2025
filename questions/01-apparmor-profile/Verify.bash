#!/bin/bash
set -uo pipefail

WORKER=$(kubectl get nodes --no-headers | grep -v control-plane | awk '{print $1}' | head -1)
PASS=true

# Check 1: AppArmor profile loaded on worker
if ssh "$WORKER" 'aa-status 2>/dev/null | grep -q nginx-profile-2'; then
  echo "✓ AppArmor profile nginx-profile-2 is loaded on $WORKER"
else
  echo "✗ AppArmor profile nginx-profile-2 NOT loaded on $WORKER"
  echo "  Hint: ssh $WORKER && apparmor_parser -q /etc/apparmor.d/nginx_apparmor"
  PASS=false
fi

# Check 2: Pod exists and is running
if kubectl get pod nginx-pod &>/dev/null; then
  STATUS=$(kubectl get pod nginx-pod -o jsonpath='{.status.phase}')
  if [ "$STATUS" = "Running" ]; then
    echo "✓ Pod nginx-pod is running"
  else
    echo "✗ Pod nginx-pod exists but status is $STATUS"
    PASS=false
  fi
else
  echo "✗ Pod nginx-pod does not exist"
  PASS=false
fi

# Check 3: Pod is scheduled on worker node
NODE=$(kubectl get pod nginx-pod -o jsonpath='{.spec.nodeName}' 2>/dev/null)
if [ "$NODE" = "$WORKER" ]; then
  echo "✓ Pod is scheduled on $WORKER"
else
  echo "✗ Pod is not on $WORKER (currently: $NODE)"
  PASS=false
fi

# Check 4: AppArmor profile is referenced in the pod spec
PROFILE=$(kubectl get pod nginx-pod -o jsonpath='{.spec.containers[0].securityContext.appArmorProfile.localhostProfile}' 2>/dev/null)
if [ "$PROFILE" = "nginx-profile-2" ]; then
  echo "✓ Pod references AppArmor profile nginx-profile-2"
else
  # Check annotation fallback (pre-1.30 style)
  ANNOT=$(kubectl get pod nginx-pod -o jsonpath='{.metadata.annotations.container\.apparmor\.security\.beta\.kubernetes\.io/nginx-pod}' 2>/dev/null)
  if [ "$ANNOT" = "localhost/nginx-profile-2" ]; then
    echo "✓ Pod references AppArmor profile via annotation"
  else
    echo "✗ Pod does not reference nginx-profile-2 AppArmor profile"
    PASS=false
  fi
fi

# Check 5: Write to /etc/ is denied by AppArmor
if kubectl exec nginx-pod -- touch /etc/apparmor-test 2>&1 | grep -qi "denied\|permission\|read-only\|cannot"; then
  echo "✓ Write to /etc/ denied by AppArmor (working correctly)"
else
  echo "✗ Write to /etc/ was NOT denied — AppArmor may not be enforcing"
  PASS=false
fi

echo ""
if [ "$PASS" = true ]; then
  echo "RESULT: PASS"
  exit 0
else
  echo "RESULT: FAIL"
  exit 1
fi
