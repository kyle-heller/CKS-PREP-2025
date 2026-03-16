#!/bin/bash
# Solution: Role Restriction
#
# Step 1: Find the Role bound to test-sa
#   kubectl get rolebindings -n database -o wide
#   # Shows: test-role-binding -> Role/test-role -> ServiceAccount/test-sa
#
#   Alternatively:
#   kubectl get rolebindings -n database -o wide | grep test-sa
#
# Step 2: Edit Role test-role to restrict to ONLY get on pods
#   kubectl edit role test-role -n database
#
#   Change the rules section from the overly broad:
#     rules:
#     - apiGroups: [""]
#       resources: ["pods", "services", "configmaps"]
#       verbs: ["get", "list", "watch", "create", "delete"]
#
#   To the restricted:
#     rules:
#     - apiGroups: [""]
#       resources: ["pods"]
#       verbs: ["get"]
#
#   Or use kubectl replace:
#   kubectl apply -f - <<'EOF'
#   apiVersion: rbac.authorization.k8s.io/v1
#   kind: Role
#   metadata:
#     name: test-role
#     namespace: database
#   rules:
#   - apiGroups: [""]
#     resources: ["pods"]
#     verbs: ["get"]
#   EOF
#
# Step 3: Create Role test-role-2 allowing update on statefulsets
#   kubectl create role test-role-2 -n database \
#     --verb=update \
#     --resource=statefulsets.apps
#
#   Note: statefulsets are in the "apps" apiGroup, so use statefulsets.apps
#   or specify --resource=statefulsets and the apiGroup will default correctly.
#
# Step 4: Create RoleBinding test-role-2-bind
#   kubectl create rolebinding test-role-2-bind -n database \
#     --role=test-role-2 \
#     --serviceaccount=database:test-sa
#
# Step 5: Verify
#   kubectl auth can-i get pods --as=system:serviceaccount:database:test-sa -n database
#   # yes
#   kubectl auth can-i list pods --as=system:serviceaccount:database:test-sa -n database
#   # no (was removed)
#   kubectl auth can-i delete pods --as=system:serviceaccount:database:test-sa -n database
#   # no (was removed)
#   kubectl auth can-i update statefulsets --as=system:serviceaccount:database:test-sa -n database
#   # yes (new role)
#
# Key concepts:
#   - Principle of least privilege: roles should grant minimum needed access
#   - Use "kubectl get rolebindings -o wide" to trace SA -> Role mappings
#   - statefulsets are in the "apps" apiGroup (not core "")
#   - A SA can have multiple RoleBindings granting different permissions
