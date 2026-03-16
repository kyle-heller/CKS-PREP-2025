#!/bin/bash
echo "=== Verify: ServiceAccount Without Secret Access ==="
PASS=true

# Check 1: ServiceAccount backend-qa exists in namespace qa
if kubectl get serviceaccount backend-qa -n qa &>/dev/null; then
  echo "[PASS] ServiceAccount backend-qa exists in namespace qa"
else
  echo "[FAIL] ServiceAccount backend-qa not found in namespace qa"
  PASS=false
fi

# Check 2: Role no-secret-access exists in namespace qa
if kubectl get role no-secret-access -n qa &>/dev/null; then
  echo "[PASS] Role no-secret-access exists in namespace qa"
else
  echo "[FAIL] Role no-secret-access not found in namespace qa"
  PASS=false
fi

# Check 3: Role allows get,list on pods
ROLE_RESOURCES=$(kubectl get role no-secret-access -n qa \
  -o jsonpath='{.rules[*].resources[*]}' 2>/dev/null)
if echo "$ROLE_RESOURCES" | grep -qw "pods"; then
  echo "[PASS] Role includes pods in resources"
else
  echo "[FAIL] Role does not include pods in resources (got: '$ROLE_RESOURCES')"
  PASS=false
fi

ROLE_VERBS=$(kubectl get role no-secret-access -n qa \
  -o jsonpath='{.rules[*].verbs[*]}' 2>/dev/null)
VERBS_OK=true
for v in get list; do
  if ! echo "$ROLE_VERBS" | grep -qw "$v"; then
    VERBS_OK=false
  fi
done
if $VERBS_OK; then
  echo "[PASS] Role has verbs: get, list"
else
  echo "[FAIL] Role missing required verbs (got: '$ROLE_VERBS', need: get, list)"
  PASS=false
fi

# Check 4: Role does NOT include secrets
if echo "$ROLE_RESOURCES" | grep -qw "secrets"; then
  echo "[FAIL] Role includes secrets — it should NOT"
  PASS=false
else
  echo "[PASS] Role does not include secrets"
fi

# Check 5: RoleBinding exists binding no-secret-access to backend-qa
BINDING_FOUND=false
for rb in $(kubectl get rolebindings -n qa -o jsonpath='{.items[*].metadata.name}' 2>/dev/null); do
  ROLE_REF=$(kubectl get rolebinding "$rb" -n qa \
    -o jsonpath='{.roleRef.name}' 2>/dev/null)
  SUBJECTS=$(kubectl get rolebinding "$rb" -n qa \
    -o jsonpath='{.subjects[*].name}' 2>/dev/null)
  if [ "$ROLE_REF" = "no-secret-access" ] && echo "$SUBJECTS" | grep -qw "backend-qa"; then
    BINDING_FOUND=true
    echo "[PASS] RoleBinding $rb binds no-secret-access to backend-qa"
    break
  fi
done
if ! $BINDING_FOUND; then
  echo "[FAIL] No RoleBinding found binding no-secret-access to backend-qa"
  PASS=false
fi

# Check 6: Pod frontend uses ServiceAccount backend-qa
POD_SA=$(kubectl get pod frontend -n qa \
  -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)
if [ "$POD_SA" = "backend-qa" ]; then
  echo "[PASS] Pod frontend uses ServiceAccount backend-qa"
else
  echo "[FAIL] Pod frontend does not use backend-qa (got: '$POD_SA')"
  PASS=false
fi

# Check 7: backend-qa cannot list secrets
CAN_LIST_SECRETS=$(kubectl auth can-i list secrets -n qa \
  --as=system:serviceaccount:qa:backend-qa 2>/dev/null)
if [ "$CAN_LIST_SECRETS" = "no" ]; then
  echo "[PASS] backend-qa cannot list secrets"
else
  echo "[FAIL] backend-qa can list secrets (should be denied)"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
