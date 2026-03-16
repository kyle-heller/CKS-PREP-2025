#!/bin/bash
set -uo pipefail
echo "=== Verify: SA Role Deployments ==="
PASS=true

# Check 1: /candidate/sa-name.txt exists
if [ -f /candidate/sa-name.txt ]; then
  echo "[PASS] /candidate/sa-name.txt exists"
else
  echo "[FAIL] /candidate/sa-name.txt not found"
  PASS=false
fi

# Check 2: sa-name.txt contains "sa-dev-1"
if grep -q "sa-dev-1" /candidate/sa-name.txt 2>/dev/null; then
  echo "[PASS] sa-name.txt contains sa-dev-1"
else
  CONTENT=$(cat /candidate/sa-name.txt 2>/dev/null || echo "<file missing>")
  echo "[FAIL] sa-name.txt should contain 'sa-dev-1' (got: '$CONTENT')"
  PASS=false
fi

# Check 3: Role dev-test-role exists in test-system
if kubectl get role dev-test-role -n test-system &>/dev/null; then
  echo "[PASS] Role dev-test-role exists in namespace test-system"
else
  echo "[FAIL] Role dev-test-role not found in namespace test-system"
  PASS=false
fi

# Check 4: Role has correct resource (deployments)
ROLE_RESOURCES=$(kubectl get role dev-test-role -n test-system -o jsonpath='{.rules[*].resources[*]}' 2>/dev/null)
if echo "$ROLE_RESOURCES" | grep -qw "deployments"; then
  echo "[PASS] Role includes resource: deployments"
else
  echo "[FAIL] Role should include 'deployments' (got: '$ROLE_RESOURCES')"
  PASS=false
fi

# Check 5: Role has correct verbs (list, get, watch)
ROLE_VERBS=$(kubectl get role dev-test-role -n test-system -o jsonpath='{.rules[*].verbs[*]}' 2>/dev/null)
VERBS_OK=true
for v in list get watch; do
  if ! echo "$ROLE_VERBS" | grep -qw "$v"; then
    VERBS_OK=false
  fi
done
if $VERBS_OK; then
  echo "[PASS] Role has verbs: list, get, watch"
else
  echo "[FAIL] Role missing required verbs (got: '$ROLE_VERBS', need: list,get,watch)"
  PASS=false
fi

# Check 6: RoleBinding dev-test-role-binding exists
if kubectl get rolebinding dev-test-role-binding -n test-system &>/dev/null; then
  echo "[PASS] RoleBinding dev-test-role-binding exists in namespace test-system"
else
  echo "[FAIL] RoleBinding dev-test-role-binding not found in namespace test-system"
  PASS=false
fi

# Check 7: RoleBinding references dev-test-role
BINDING_ROLE=$(kubectl get rolebinding dev-test-role-binding -n test-system -o jsonpath='{.roleRef.name}' 2>/dev/null)
if [ "$BINDING_ROLE" = "dev-test-role" ]; then
  echo "[PASS] RoleBinding references Role dev-test-role"
else
  echo "[FAIL] RoleBinding should reference 'dev-test-role' (got: '$BINDING_ROLE')"
  PASS=false
fi

# Check 8: RoleBinding binds to sa-dev-1 ServiceAccount
BINDING_SA=$(kubectl get rolebinding dev-test-role-binding -n test-system -o jsonpath='{.subjects[?(@.kind=="ServiceAccount")].name}' 2>/dev/null)
if [ "$BINDING_SA" = "sa-dev-1" ]; then
  echo "[PASS] RoleBinding binds to ServiceAccount sa-dev-1"
else
  echo "[FAIL] RoleBinding should bind to 'sa-dev-1' (got: '$BINDING_SA')"
  PASS=false
fi

# Check 9: auth can-i verification
if kubectl auth can-i list deployments -n test-system --as=system:serviceaccount:test-system:sa-dev-1 2>/dev/null | grep -q "yes"; then
  echo "[PASS] sa-dev-1 can list deployments in test-system"
else
  echo "[FAIL] sa-dev-1 cannot list deployments in test-system"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
