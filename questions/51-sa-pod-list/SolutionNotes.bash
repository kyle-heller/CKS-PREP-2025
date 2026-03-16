#!/bin/bash
# Solution: ServiceAccount with Pod List Permissions
#
# Step 1: Create the ServiceAccount
#   kubectl create sa backend-sa
#
# Step 2: Create the Role
#   kubectl create role pod-reader --verb=list,get --resource=pods
#
# Step 3: Create the RoleBinding
#   kubectl create rolebinding pod-reader-binding \
#     --role=pod-reader \
#     --serviceaccount=default:backend-sa
#
# Step 4: Create the Pod with the ServiceAccount
#   cat <<EOF | kubectl apply -f -
#   apiVersion: v1
#   kind: Pod
#   metadata:
#     name: backend-pod
#   spec:
#     serviceAccountName: backend-sa
#     containers:
#     - name: kubectl
#       image: bitnami/kubectl:latest
#       command: ["sleep", "3600"]
#   EOF
#
# Verification (from inside the pod):
#   kubectl exec backend-pod -- kubectl get pods
#   # Should succeed — SA has list,get on pods
#
#   kubectl exec backend-pod -- kubectl delete pod backend-pod
#   # Should fail — SA does not have delete permission
#
# Key concepts:
# - ServiceAccounts provide pod identity within the cluster
# - Roles define what actions are allowed on which resources
# - RoleBindings connect a Role to a subject (SA, user, group)
# - Always use least-privilege: only grant the verbs and resources needed
# - Role/RoleBinding = namespace-scoped; ClusterRole/ClusterRoleBinding = cluster-wide
# - The --serviceaccount flag format is namespace:name
