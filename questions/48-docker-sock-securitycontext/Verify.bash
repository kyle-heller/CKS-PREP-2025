#!/bin/bash
set -uo pipefail
echo "=== Verify: Docker Socket SecurityContext ==="
PASS=true

# Check 1: Deployment docker-admin exists in sandbox
if kubectl get deployment docker-admin -n sandbox &>/dev/null; then
  echo "[PASS] Deployment docker-admin exists in namespace sandbox"
else
  echo "[FAIL] Deployment docker-admin not found in namespace sandbox"
  PASS=false
  $PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
  exit 0
fi

# Get container spec via jsonpath (first container)
CTR_PATH='.spec.template.spec.containers[0]'

# Check 2: runAsUser = 65535
RUN_AS_USER=$(kubectl get deploy docker-admin -n sandbox -o jsonpath="{${CTR_PATH}.securityContext.runAsUser}" 2>/dev/null)
if [ "$RUN_AS_USER" = "65535" ]; then
  echo "[PASS] runAsUser is 65535"
else
  echo "[FAIL] runAsUser should be 65535 (got: '$RUN_AS_USER')"
  PASS=false
fi

# Check 3: runAsGroup = 65535
RUN_AS_GROUP=$(kubectl get deploy docker-admin -n sandbox -o jsonpath="{${CTR_PATH}.securityContext.runAsGroup}" 2>/dev/null)
if [ "$RUN_AS_GROUP" = "65535" ]; then
  echo "[PASS] runAsGroup is 65535"
else
  echo "[FAIL] runAsGroup should be 65535 (got: '$RUN_AS_GROUP')"
  PASS=false
fi

# Check 4: readOnlyRootFilesystem = true
READ_ONLY=$(kubectl get deploy docker-admin -n sandbox -o jsonpath="{${CTR_PATH}.securityContext.readOnlyRootFilesystem}" 2>/dev/null)
if [ "$READ_ONLY" = "true" ]; then
  echo "[PASS] readOnlyRootFilesystem is true"
else
  echo "[FAIL] readOnlyRootFilesystem should be true (got: '$READ_ONLY')"
  PASS=false
fi

# Check 5: allowPrivilegeEscalation = false
ALLOW_PE=$(kubectl get deploy docker-admin -n sandbox -o jsonpath="{${CTR_PATH}.securityContext.allowPrivilegeEscalation}" 2>/dev/null)
if [ "$ALLOW_PE" = "false" ]; then
  echo "[PASS] allowPrivilegeEscalation is false"
else
  echo "[FAIL] allowPrivilegeEscalation should be false (got: '$ALLOW_PE')"
  PASS=false
fi

# Check 6: capabilities drop includes ALL
DROP_CAPS=$(kubectl get deploy docker-admin -n sandbox -o jsonpath="{${CTR_PATH}.securityContext.capabilities.drop[*]}" 2>/dev/null)
if echo "$DROP_CAPS" | grep -qi "ALL"; then
  echo "[PASS] Capabilities drop includes ALL"
else
  echo "[FAIL] Capabilities should drop ALL (got: '$DROP_CAPS')"
  PASS=false
fi

# Check 7: docker.sock volume mount still present
MOUNT_PATH=$(kubectl get deploy docker-admin -n sandbox -o jsonpath="{${CTR_PATH}.volumeMounts[?(@.name=='dockersock')].mountPath}" 2>/dev/null)
if [ "$MOUNT_PATH" = "/var/run/docker.sock" ]; then
  echo "[PASS] docker.sock volume mount still present"
else
  echo "[FAIL] docker.sock volume mount is missing"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
