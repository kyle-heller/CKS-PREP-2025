#!/bin/bash
echo "=== Verify: ServiceAccount Pod List ==="
PASS=true

# Check 1: ServiceAccount backend-sa exists
SA=$(kubectl get sa backend-sa -o jsonpath='{.metadata.name}' 2>/dev/null)
if [ "$SA" = "backend-sa" ]; then
  echo "[PASS] ServiceAccount backend-sa exists"
else
  echo "[FAIL] ServiceAccount backend-sa not found"
  PASS=false
fi

# Check 2: Role pod-reader exists with correct verbs and resources
ROLE=$(kubectl get role pod-reader -o jsonpath='{.metadata.name}' 2>/dev/null)
if [ "$ROLE" = "pod-reader" ]; then
  echo "[PASS] Role pod-reader exists"
else
  echo "[FAIL] Role pod-reader not found"
  PASS=false
fi

VERBS=$(kubectl get role pod-reader -o jsonpath='{.rules[0].verbs[*]}' 2>/dev/null)
if echo "$VERBS" | grep -q "list" && echo "$VERBS" | grep -q "get"; then
  echo "[PASS] Role has list and get verbs"
else
  echo "[FAIL] Role verbs: $VERBS (need list, get)"
  PASS=false
fi

RESOURCES=$(kubectl get role pod-reader -o jsonpath='{.rules[0].resources[*]}' 2>/dev/null)
if echo "$RESOURCES" | grep -q "pods"; then
  echo "[PASS] Role targets pods resource"
else
  echo "[FAIL] Role resources: $RESOURCES (need pods)"
  PASS=false
fi

# Check 3: RoleBinding pod-reader-binding exists and binds correctly
RB=$(kubectl get rolebinding pod-reader-binding -o jsonpath='{.metadata.name}' 2>/dev/null)
if [ "$RB" = "pod-reader-binding" ]; then
  echo "[PASS] RoleBinding pod-reader-binding exists"
else
  echo "[FAIL] RoleBinding pod-reader-binding not found"
  PASS=false
fi

RB_ROLE=$(kubectl get rolebinding pod-reader-binding -o jsonpath='{.roleRef.name}' 2>/dev/null)
if [ "$RB_ROLE" = "pod-reader" ]; then
  echo "[PASS] RoleBinding references Role pod-reader"
else
  echo "[FAIL] RoleBinding roleRef: $RB_ROLE (expected pod-reader)"
  PASS=false
fi

RB_SA=$(kubectl get rolebinding pod-reader-binding -o jsonpath='{.subjects[0].name}' 2>/dev/null)
if [ "$RB_SA" = "backend-sa" ]; then
  echo "[PASS] RoleBinding subject is backend-sa"
else
  echo "[FAIL] RoleBinding subject: $RB_SA (expected backend-sa)"
  PASS=false
fi

# Check 4: Pod backend-pod exists with correct SA
POD=$(kubectl get pod backend-pod -o jsonpath='{.metadata.name}' 2>/dev/null)
if [ "$POD" = "backend-pod" ]; then
  echo "[PASS] Pod backend-pod exists"
else
  echo "[FAIL] Pod backend-pod not found"
  PASS=false
fi

POD_SA=$(kubectl get pod backend-pod -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)
if [ "$POD_SA" = "backend-sa" ]; then
  echo "[PASS] Pod uses serviceAccountName: backend-sa"
else
  echo "[FAIL] Pod serviceAccountName: $POD_SA (expected backend-sa)"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
