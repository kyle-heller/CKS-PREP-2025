# CKS Practice — Re-secure the API Server
# Domain: Cluster Hardening (15%)
#
# The cluster's API server was temporarily configured to allow
# unauthenticated + unauthorized access (anonymous user had cluster-admin).
#
# Re-secure the cluster so that only authenticated and authorized REST requests are allowed.
#
# Requirements:
# 1. Use authorization mode Node,RBAC.
# 2. Use admission controller NodeRestriction.
# 3. Disable --anonymous-auth.
# 4. Remove ClusterRoleBinding that grants access to system:anonymous.
# 5. After the fix, use the original kubeconfig /etc/kubernetes/admin.conf.
