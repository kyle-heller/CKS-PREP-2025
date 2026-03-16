#!/bin/bash
# Solution: Re-secure the API Server
#
# Step 1: Edit /etc/kubernetes/manifests/kube-apiserver.yaml
#   - --authorization-mode=Node,RBAC
#   - --enable-admission-plugins=NodeRestriction
#   - --anonymous-auth=false
#   - --client-ca-file=/etc/kubernetes/pki/ca.crt   (should already be there)
#
# Step 2: Remove anonymous ClusterRoleBinding
#   kubectl delete clusterrolebinding system:anonymous
#
# Step 3: Wait for API server to restart (~30s)
#   kubectl get pods -n kube-system --kubeconfig /etc/kubernetes/admin.conf
#
# Notes:
# - --anonymous-auth=false ensures no unauthenticated requests are processed
# - Authorization is enforced via Node + RBAC (Node authorizer for kubelet requests)
# - NodeRestriction admission controller prevents kubelets from modifying
#   objects outside their scope (e.g., other nodes' resources)
# - --client-ca-file ensures secure x509 communication between API server and clients
# - AlwaysAllow/AlwaysAdmit should NEVER be used in production
# - After removing the ClusterRoleBinding, anonymous users lose all access
