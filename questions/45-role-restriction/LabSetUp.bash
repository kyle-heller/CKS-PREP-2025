#!/bin/bash
set -euo pipefail

# Create namespace
kubectl create namespace database --dry-run=client -o yaml | kubectl apply -f -

# Create ServiceAccount
kubectl create serviceaccount test-sa -n database --dry-run=client -o yaml | kubectl apply -f -

# Create Role with overly broad permissions (student must restrict to get on pods only)
kubectl apply -f - <<'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: test-role
  namespace: database
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps"]
  verbs: ["get", "list", "watch", "create", "delete"]
EOF

# Create RoleBinding binding test-role to test-sa
kubectl apply -f - <<'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: test-role-binding
  namespace: database
subjects:
- kind: ServiceAccount
  name: test-sa
  namespace: database
roleRef:
  kind: Role
  name: test-role
  apiGroup: rbac.authorization.k8s.io
EOF

echo "Lab setup complete."
echo "  Namespace: database"
echo "  ServiceAccount: test-sa"
echo "  Role: test-role (overly permissive — get,list,watch,create,delete on pods,services,configmaps)"
echo "  RoleBinding: test-role-binding (binds test-role to test-sa)"
echo "  Task: Restrict test-role, create test-role-2, bind with test-role-2-bind"
