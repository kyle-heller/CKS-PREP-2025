#!/bin/bash
# CKS Practice — ServiceAccount Without Secret Access — Solution Notes
# Domain: Cluster Hardening (15%)

# Step 1: Create ServiceAccount backend-qa in namespace qa
# kubectl create serviceaccount backend-qa -n qa
#
# Or declaratively:
# kubectl apply -f - <<'EOF'
# apiVersion: v1
# kind: ServiceAccount
# metadata:
#   name: backend-qa
#   namespace: qa
# EOF

# Step 2: Create Role no-secret-access that allows get,list on pods only
# kubectl create role no-secret-access -n qa \
#   --verb=get,list --resource=pods
#
# Or declaratively:
# kubectl apply -f - <<'EOF'
# apiVersion: rbac.authorization.k8s.io/v1
# kind: Role
# metadata:
#   name: no-secret-access
#   namespace: qa
# rules:
# - apiGroups: [""]
#   resources: ["pods"]
#   verbs: ["get", "list"]
# EOF
#
# Key: Only "pods" in resources — no "secrets" anywhere.

# Step 3: Create RoleBinding to bind the Role to backend-qa
# kubectl create rolebinding backend-qa-binding -n qa \
#   --role=no-secret-access --serviceaccount=qa:backend-qa
#
# Or declaratively:
# kubectl apply -f - <<'EOF'
# apiVersion: rbac.authorization.k8s.io/v1
# kind: RoleBinding
# metadata:
#   name: backend-qa-binding
#   namespace: qa
# subjects:
# - kind: ServiceAccount
#   name: backend-qa
#   namespace: qa
# roleRef:
#   kind: Role
#   name: no-secret-access
#   apiGroup: rbac.authorization.k8s.io
# EOF

# Step 4: Update Pod frontend to use ServiceAccount backend-qa
# Pods are immutable for serviceAccountName — delete and recreate.
#
# kubectl get pod frontend -n qa -o yaml > /tmp/frontend.yaml
# kubectl delete pod frontend -n qa
#
# Edit /tmp/frontend.yaml:
#   spec:
#     serviceAccountName: backend-qa    # <-- add this line
#
# kubectl apply -f /tmp/frontend.yaml
#
# Or as a one-liner (export, modify, recreate):
# kubectl get pod frontend -n qa -o json | \
#   python3 -c "import json,sys; p=json.load(sys.stdin); p['spec']['serviceAccountName']='backend-qa'; del p['metadata']['resourceVersion']; del p['metadata']['uid']; del p['status']; json.dump(p,sys.stdout)" | \
#   kubectl replace --force -f -

# Step 5: Verify permissions
# kubectl auth can-i list pods -n qa --as=system:serviceaccount:qa:backend-qa
# Expected: yes
#
# kubectl auth can-i list secrets -n qa --as=system:serviceaccount:qa:backend-qa
# Expected: no
#
# kubectl auth can-i get secrets -n qa --as=system:serviceaccount:qa:backend-qa
# Expected: no

# Key concepts:
# - RBAC follows least privilege: only grant what is explicitly needed
# - Roles are namespace-scoped (ClusterRoles are cluster-wide)
# - serviceAccountName in pod spec is immutable — must delete and recreate
# - "kubectl auth can-i" with --as flag impersonates any user/SA for testing
# - On the exam: use "kubectl create role/rolebinding" imperative commands to save time
# - The default SA in a namespace may have broader permissions via ClusterRoleBindings
