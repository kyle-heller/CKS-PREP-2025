# CKS Practice — kube-bench Fixes
# Domain: Cluster Setup (15%)
#
# Run kube-bench against the cluster and fix all security violations found.
#
# API Server (/etc/kubernetes/manifests/kube-apiserver.yaml):
#   - Ensure --kubelet-certificate-authority is set to /etc/kubernetes/pki/ca.crt
#   - Ensure --profiling is disabled (set to false or remove the flag)
#
# Kubelet (/var/lib/kubelet/config.yaml):
#   - Disable anonymous authentication
#   - Set authorization mode to Webhook
#   - Restart kubelet after changes
#
# ETCD (/etc/kubernetes/manifests/etcd.yaml):
#   - Ensure --auto-tls is not set to true
#   - Ensure --peer-auto-tls is not set to true
#
# After fixing, verify the cluster is healthy with: kubectl get nodes
