#!/bin/bash
echo "=== Verify: User CSR and RBAC ==="
PASS=true

# Check 1: CSR exists and is approved
CSR_STATUS=$(kubectl get csr john-csr -o jsonpath='{.status.conditions[0].type}' 2>/dev/null)
if [ "$CSR_STATUS" = "Approved" ]; then
  echo "[PASS] CSR john-csr is Approved"
else
  echo "[FAIL] CSR john-csr not found or not Approved (status: '$CSR_STATUS')"
  PASS=false
fi

# Check 2: Role john-role exists in namespace john
if kubectl get role john-role -n john &>/dev/null; then
  echo "[PASS] Role john-role exists in namespace john"
else
  echo "[FAIL] Role john-role not found in namespace john"
  PASS=false
fi

# Check 3: Role has correct resources (pods, secrets)
ROLE_RESOURCES=$(kubectl get role john-role -n john -o jsonpath='{.rules[*].resources[*]}' 2>/dev/null)
if echo "$ROLE_RESOURCES" | grep -qw "pods" && echo "$ROLE_RESOURCES" | grep -qw "secrets"; then
  echo "[PASS] Role includes pods and secrets"
else
  echo "[FAIL] Role resources should include pods and secrets (got: '$ROLE_RESOURCES')"
  PASS=false
fi

# Check 4: Role has correct verbs (list, get, create, delete)
ROLE_VERBS=$(kubectl get role john-role -n john -o jsonpath='{.rules[*].verbs[*]}' 2>/dev/null)
VERBS_OK=true
for v in list get create delete; do
  if ! echo "$ROLE_VERBS" | grep -qw "$v"; then
    VERBS_OK=false
  fi
done
if $VERBS_OK; then
  echo "[PASS] Role has verbs: list, get, create, delete"
else
  echo "[FAIL] Role missing required verbs (got: '$ROLE_VERBS', need: list,get,create,delete)"
  PASS=false
fi

# Check 5: RoleBinding exists
if kubectl get rolebinding john-role-binding -n john &>/dev/null; then
  echo "[PASS] RoleBinding john-role-binding exists"
else
  echo "[FAIL] RoleBinding john-role-binding not found in namespace john"
  PASS=false
fi

# Check 6: auth can-i checks
if kubectl auth can-i create pods -n john --as john 2>/dev/null | grep -q "yes"; then
  echo "[PASS] john can create pods in namespace john"
else
  echo "[FAIL] john cannot create pods in namespace john"
  PASS=false
fi

if kubectl auth can-i create deployments -n john --as john 2>/dev/null | grep -q "no"; then
  echo "[PASS] john cannot create deployments (correct — not in role)"
else
  echo "[FAIL] john can create deployments (should not be allowed)"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
