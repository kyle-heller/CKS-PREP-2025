# CKS Practice — kube-bench Fixes
# Domain: Cluster Setup (15%)
#
# Fix multiple security violations identified by kube-bench.
#
# API Server:
#   - Enable RotateKubeletServerCertificate.
#   - Enable admission plugin PodSecurityPolicy.
#   - Set --kubelet-certificate-authority argument.
#
# Kubelet:
#   - Disable anonymous authentication.
#   - Set authorization-mode to Webhook.
#
# ETCD:
#   - Ensure --auto-tls is not true.
#   - Ensure --peer-auto-tls is not true.
