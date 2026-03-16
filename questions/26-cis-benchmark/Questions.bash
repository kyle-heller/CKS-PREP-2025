# CKS Practice — CIS Benchmark Fixes
# Domain: Cluster Setup (15%)
#
# Security violations have been introduced in the cluster configuration.
# Run kube-bench and fix the following:
#
# 1. API Server (/etc/kubernetes/manifests/kube-apiserver.yaml):
#    - authorization-mode must include both Node and RBAC
#
# 2. Kubelet (/var/lib/kubelet/config.yaml):
#    - Disable anonymous authentication
#    - Set authorization mode to Webhook
#    - Restart kubelet after changes
#
# 3. etcd (/etc/kubernetes/manifests/etcd.yaml):
#    - Enable --client-cert-auth=true
#    - Remove --auto-tls=true
#
# Verify: kube-bench run --targets=master,node,etcd
