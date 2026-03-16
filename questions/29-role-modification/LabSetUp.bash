#!/bin/bash
set -euo pipefail

# Create namespace and RBAC resources for role modification exercise
kubectl create namespace security --dry-run=client -o yaml | kubectl apply -f -

# Create ServiceAccount
kubectl create serviceaccount sa-dev-1 -n security --dry-run=client -o yaml | kubectl apply -f -

# Create Role with broad permissions (student must restrict to watch on services only)
kubectl apply -f - <<'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: role-1
  namespace: security
rules:
- apiGroups: [""]
  resources: ["pods", "services", "deployments"]
  verbs: ["get", "list", "watch", "create", "delete"]
EOF

# Create RoleBinding
kubectl apply -f - <<'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: role-1-binding
  namespace: security
subjects:
- kind: ServiceAccount
  name: sa-dev-1
  namespace: security
roleRef:
  kind: Role
  name: role-1
  apiGroup: rbac.authorization.k8s.io
EOF

echo "Lab setup complete."
echo "  Namespace: security"
echo "  ServiceAccount: sa-dev-1"
echo "  Role: role-1 (overly permissive — get,list,watch,create,delete on pods,services,deployments)"
echo "  RoleBinding: role-1-binding"
