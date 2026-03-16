#!/bin/bash
echo "=== Verify: Role Restriction ==="
PASS=true

# Check 1: Role test-role exists and has ONLY get on pods
ROLE_RESOURCES=$(kubectl get role test-role -n database -o jsonpath='{.rules[*].resources[*]}' 2>/dev/null)
ROLE_VERBS=$(kubectl get role test-role -n database -o jsonpath='{.rules[*].verbs[*]}' 2>/dev/null)

if [ -n "$ROLE_RESOURCES" ]; then
  if echo "$ROLE_RESOURCES" | grep -qw "pods"; then
    echo "[PASS] Role test-role includes pods"
  else
    echo "[FAIL] Role test-role does not include pods (got: $ROLE_RESOURCES)"
    PASS=false
  fi

  # Should NOT have services or configmaps
  if echo "$ROLE_RESOURCES" | grep -qwE "services|configmaps"; then
    echo "[FAIL] Role test-role still has services or configmaps (got: $ROLE_RESOURCES)"
    PASS=false
  else
    echo "[PASS] Role test-role does not include services or configmaps"
  fi

  # Verbs should be only get
  if [ "$ROLE_VERBS" = "get" ]; then
    echo "[PASS] Role test-role has only 'get' verb"
  else
    echo "[FAIL] Role test-role verbs should be only 'get' (got: $ROLE_VERBS)"
    PASS=false
  fi
else
  echo "[FAIL] Role test-role not found in database namespace"
  PASS=false
fi

# Check 2: Role test-role-2 exists with update on statefulsets
ROLE2_RESOURCES=$(kubectl get role test-role-2 -n database -o jsonpath='{.rules[*].resources[*]}' 2>/dev/null)
ROLE2_VERBS=$(kubectl get role test-role-2 -n database -o jsonpath='{.rules[*].verbs[*]}' 2>/dev/null)
ROLE2_APIGROUPS=$(kubectl get role test-role-2 -n database -o jsonpath='{.rules[*].apiGroups[*]}' 2>/dev/null)

if [ -n "$ROLE2_RESOURCES" ]; then
  if echo "$ROLE2_RESOURCES" | grep -qw "statefulsets"; then
    echo "[PASS] Role test-role-2 includes statefulsets"
  else
    echo "[FAIL] Role test-role-2 does not include statefulsets (got: $ROLE2_RESOURCES)"
    PASS=false
  fi

  if echo "$ROLE2_VERBS" | grep -qw "update"; then
    echo "[PASS] Role test-role-2 has 'update' verb"
  else
    echo "[FAIL] Role test-role-2 missing 'update' verb (got: $ROLE2_VERBS)"
    PASS=false
  fi

  if echo "$ROLE2_APIGROUPS" | grep -qw "apps"; then
    echo "[PASS] Role test-role-2 uses apiGroup 'apps'"
  else
    echo "[FAIL] Role test-role-2 missing apiGroup 'apps' (got: $ROLE2_APIGROUPS)"
    PASS=false
  fi
else
  echo "[FAIL] Role test-role-2 not found in database namespace"
  PASS=false
fi

# Check 3: RoleBinding test-role-2-bind exists and references correct role and SA
RB_ROLE=$(kubectl get rolebinding test-role-2-bind -n database -o jsonpath='{.roleRef.name}' 2>/dev/null)
RB_SA=$(kubectl get rolebinding test-role-2-bind -n database -o jsonpath='{.subjects[0].name}' 2>/dev/null)

if [ "$RB_ROLE" = "test-role-2" ]; then
  echo "[PASS] RoleBinding test-role-2-bind references Role test-role-2"
else
  echo "[FAIL] RoleBinding test-role-2-bind not found or wrong roleRef (got: '$RB_ROLE')"
  PASS=false
fi

if [ "$RB_SA" = "test-sa" ]; then
  echo "[PASS] RoleBinding test-role-2-bind binds to test-sa"
else
  echo "[FAIL] RoleBinding test-role-2-bind does not bind to test-sa (got: '$RB_SA')"
  PASS=false
fi

# Check 4: auth can-i verification
if kubectl auth can-i get pods --as=system:serviceaccount:database:test-sa -n database 2>/dev/null | grep -q "yes"; then
  echo "[PASS] test-sa can get pods in database"
else
  echo "[FAIL] test-sa cannot get pods in database"
  PASS=false
fi

if kubectl auth can-i update statefulsets --as=system:serviceaccount:database:test-sa -n database 2>/dev/null | grep -q "yes"; then
  echo "[PASS] test-sa can update statefulsets in database"
else
  echo "[FAIL] test-sa cannot update statefulsets in database"
  PASS=false
fi

# Negative check: should NOT be able to delete pods anymore
if kubectl auth can-i delete pods --as=system:serviceaccount:database:test-sa -n database 2>/dev/null | grep -q "no"; then
  echo "[PASS] test-sa cannot delete pods (correctly restricted)"
else
  echo "[FAIL] test-sa can still delete pods (role not properly restricted)"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
