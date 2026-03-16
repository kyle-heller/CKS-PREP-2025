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
