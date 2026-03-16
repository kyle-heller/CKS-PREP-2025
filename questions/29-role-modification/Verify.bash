#!/bin/bash
echo "=== Verify: Role Modification ==="
PASS=true

# Check 1: Role role-1 exists and has ONLY watch on services
ROLE_RESOURCES=$(kubectl get role role-1 -n security -o jsonpath='{.rules[*].resources[*]}' 2>/dev/null)
ROLE_VERBS=$(kubectl get role role-1 -n security -o jsonpath='{.rules[*].verbs[*]}' 2>/dev/null)

if [ -n "$ROLE_RESOURCES" ]; then
  if echo "$ROLE_RESOURCES" | grep -qw "services"; then
    echo "[PASS] Role role-1 includes services"
  else
    echo "[FAIL] Role role-1 does not include services (got: $ROLE_RESOURCES)"
    PASS=false
  fi

  # Should NOT have pods or deployments
  if echo "$ROLE_RESOURCES" | grep -qwE "pods|deployments"; then
    echo "[FAIL] Role role-1 still has pods or deployments (got: $ROLE_RESOURCES)"
    PASS=false
  else
    echo "[PASS] Role role-1 does not include pods or deployments"
  fi

  # Verbs should be only watch
  if [ "$ROLE_VERBS" = "watch" ]; then
    echo "[PASS] Role role-1 has only 'watch' verb"
  else
    echo "[FAIL] Role role-1 verbs should be only 'watch' (got: $ROLE_VERBS)"
    PASS=false
  fi
else
  echo "[FAIL] Role role-1 not found in security namespace"
  PASS=false
fi

# Check 2: ClusterRole role-2 exists with update on namespaces
CR_RESOURCES=$(kubectl get clusterrole role-2 -o jsonpath='{.rules[*].resources[*]}' 2>/dev/null)
CR_VERBS=$(kubectl get clusterrole role-2 -o jsonpath='{.rules[*].verbs[*]}' 2>/dev/null)

if [ -n "$CR_RESOURCES" ]; then
  if echo "$CR_RESOURCES" | grep -qw "namespaces"; then
    echo "[PASS] ClusterRole role-2 includes namespaces"
  else
    echo "[FAIL] ClusterRole role-2 does not include namespaces (got: $CR_RESOURCES)"
    PASS=false
  fi

  if echo "$CR_VERBS" | grep -qw "update"; then
    echo "[PASS] ClusterRole role-2 has 'update' verb"
  else
    echo "[FAIL] ClusterRole role-2 missing 'update' verb (got: $CR_VERBS)"
    PASS=false
  fi
else
  echo "[FAIL] ClusterRole role-2 not found"
  PASS=false
fi

# Check 3: ClusterRoleBinding role-2-binding exists and binds to sa-dev-1
CRB_SA=$(kubectl get clusterrolebinding role-2-binding -o jsonpath='{.subjects[0].name}' 2>/dev/null)
CRB_ROLE=$(kubectl get clusterrolebinding role-2-binding -o jsonpath='{.roleRef.name}' 2>/dev/null)

if [ "$CRB_ROLE" = "role-2" ]; then
  echo "[PASS] ClusterRoleBinding role-2-binding references ClusterRole role-2"
else
  echo "[FAIL] ClusterRoleBinding role-2-binding not found or wrong roleRef (got: '$CRB_ROLE')"
  PASS=false
fi

if [ "$CRB_SA" = "sa-dev-1" ]; then
  echo "[PASS] ClusterRoleBinding binds to sa-dev-1"
else
  echo "[FAIL] ClusterRoleBinding does not bind to sa-dev-1 (got: '$CRB_SA')"
  PASS=false
fi

# Check 4: auth can-i verification
if kubectl auth can-i watch services --as=system:serviceaccount:security:sa-dev-1 -n security 2>/dev/null | grep -q "yes"; then
  echo "[PASS] sa-dev-1 can watch services in security"
else
  echo "[FAIL] sa-dev-1 cannot watch services in security"
  PASS=false
fi

if kubectl auth can-i update namespaces --as=system:serviceaccount:security:sa-dev-1 2>/dev/null | grep -q "yes"; then
  echo "[PASS] sa-dev-1 can update namespaces (cluster-wide)"
else
  echo "[FAIL] sa-dev-1 cannot update namespaces"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
