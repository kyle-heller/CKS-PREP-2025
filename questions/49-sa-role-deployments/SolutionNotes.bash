#!/bin/bash
# Solution: ServiceAccount Role for Deployments
#
# Step 1: Find the ServiceAccount used by nginx-pod
#   kubectl get pod nginx-pod -n test-system -o jsonpath='{.spec.serviceAccountName}'
#   # Output: sa-dev-1
#
# Step 2: Save the SA name to the output file
#   echo "sa-dev-1" > /candidate/sa-name.txt
#
#   OR in one command:
#   kubectl get pod nginx-pod -n test-system -o jsonpath='{.spec.serviceAccountName}' > /candidate/sa-name.txt
#
# Step 3: Create the Role
#   kubectl create role dev-test-role \
#     --verb=list,get,watch \
#     --resource=deployments \
#     -n test-system
#
# Step 4: Create the RoleBinding
#   kubectl create rolebinding dev-test-role-binding \
#     --role=dev-test-role \
#     --serviceaccount=test-system:sa-dev-1 \
#     -n test-system
#
# Step 5: Verify
#   kubectl auth can-i list deployments -n test-system \
#     --as=system:serviceaccount:test-system:sa-dev-1
#   # Output: yes
#
#   kubectl auth can-i create deployments -n test-system \
#     --as=system:serviceaccount:test-system:sa-dev-1
#   # Output: no (only list/get/watch allowed)
#
# Key concepts:
# - ServiceAccount name is at .spec.serviceAccountName in the Pod spec
# - Roles define permissions (verbs + resources) within a namespace
# - RoleBindings link a Role to a subject (User, Group, or ServiceAccount)
# - For ServiceAccounts, the --serviceaccount flag format is namespace:name
# - kubectl auth can-i is essential for verifying RBAC permissions
# - Principle of least privilege: only grant the minimum verbs needed
