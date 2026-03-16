#!/bin/bash
echo "=== Verify: Docker Socket Permissions ==="
PASS=true

# Check 1: Pod docker-builder exists in ci-cd
if kubectl get pod docker-builder -n ci-cd &>/dev/null; then
  echo "[PASS] Pod docker-builder exists in namespace ci-cd"
else
  echo "[FAIL] Pod docker-builder not found in namespace ci-cd"
  PASS=false
fi

# Check 2: runAsUser is 65535
RUN_AS_USER=$(kubectl get pod docker-builder -n ci-cd \
  -o jsonpath='{.spec.containers[0].securityContext.runAsUser}' 2>/dev/null)
if [ "$RUN_AS_USER" = "65535" ]; then
  echo "[PASS] runAsUser is 65535"
else
  echo "[FAIL] runAsUser is not 65535 (got: '$RUN_AS_USER')"
  PASS=false
fi

# Check 3: runAsGroup is 65535
RUN_AS_GROUP=$(kubectl get pod docker-builder -n ci-cd \
  -o jsonpath='{.spec.containers[0].securityContext.runAsGroup}' 2>/dev/null)
if [ -z "$RUN_AS_GROUP" ]; then
  # Check pod-level securityContext
  RUN_AS_GROUP=$(kubectl get pod docker-builder -n ci-cd \
    -o jsonpath='{.spec.securityContext.runAsGroup}' 2>/dev/null)
fi
if [ "$RUN_AS_GROUP" = "65535" ]; then
  echo "[PASS] runAsGroup is 65535"
else
  echo "[FAIL] runAsGroup is not 65535 (got: '$RUN_AS_GROUP')"
  PASS=false
fi

# Check 4: readOnlyRootFilesystem is true
READ_ONLY=$(kubectl get pod docker-builder -n ci-cd \
  -o jsonpath='{.spec.containers[0].securityContext.readOnlyRootFilesystem}' 2>/dev/null)
if [ "$READ_ONLY" = "true" ]; then
  echo "[PASS] readOnlyRootFilesystem is true"
else
  echo "[FAIL] readOnlyRootFilesystem is not true (got: '$READ_ONLY')"
  PASS=false
fi

# Check 5: allowPrivilegeEscalation is false
ALLOW_PRIV=$(kubectl get pod docker-builder -n ci-cd \
  -o jsonpath='{.spec.containers[0].securityContext.allowPrivilegeEscalation}' 2>/dev/null)
if [ "$ALLOW_PRIV" = "false" ]; then
  echo "[PASS] allowPrivilegeEscalation is false"
else
  echo "[FAIL] allowPrivilegeEscalation is not false (got: '$ALLOW_PRIV')"
  PASS=false
fi

# Check 6: capabilities drop ALL
DROP_CAPS=$(kubectl get pod docker-builder -n ci-cd \
  -o jsonpath='{.spec.containers[0].securityContext.capabilities.drop[*]}' 2>/dev/null)
if echo "$DROP_CAPS" | grep -qi "ALL"; then
  echo "[PASS] capabilities drop includes ALL"
else
  echo "[FAIL] capabilities drop does not include ALL (got: '$DROP_CAPS')"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
