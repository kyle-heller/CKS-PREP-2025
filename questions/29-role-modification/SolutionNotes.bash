#!/bin/bash
# Solution: Role Modification and ClusterRole
#
# Step 1: Find the Role bound to sa-dev-1
#   kubectl get rolebindings -n security -o wide | grep sa-dev-1
#   # Shows role-1-binding -> Role role-1
#
# Step 2: Edit Role role-1 to restrict to watch on services only
#   kubectl edit role role-1 -n security
#
#   Change the rules section to:
#   rules:
#   - apiGroups: [""]
#     resources: ["services"]
#     verbs: ["watch"]
#
# Step 3: Create ClusterRole role-2 allowing update on namespaces
#   kubectl create clusterrole role-2 --verb=update --resource=namespaces
#
# Step 4: Bind with ClusterRoleBinding role-2-binding
#   kubectl create clusterrolebinding role-2-binding \
#     --clusterrole=role-2 \
#     --serviceaccount=security:sa-dev-1
#
# Step 5: Verify
#   kubectl auth can-i watch services --as=system:serviceaccount:security:sa-dev-1 -n security
#   # yes
#   kubectl auth can-i create pods --as=system:serviceaccount:security:sa-dev-1 -n security
#   # no (was removed)
#   kubectl auth can-i update namespaces --as=system:serviceaccount:security:sa-dev-1
#   # yes
