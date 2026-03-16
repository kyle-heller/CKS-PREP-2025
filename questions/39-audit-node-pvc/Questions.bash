# CKS Practice — Audit: Node and PVC Changes
# Domain: Monitoring, Logging and Runtime Security (20%)
#
# Configure Kubernetes audit logging for the cluster.
#
# 1. Configure the API server to write audit logs to:
#      /var/log/kubernetes-logs.log
#    With the following retention settings:
#      - Retain logs for 5 days
#      - Keep a maximum of 10 backup files
#
# 2. Create an audit policy at /etc/audit/audit-policy.yaml with rules:
#    - Log all Node resource changes at the RequestResponse level
#    - Log PersistentVolumeClaim changes in the frontend namespace at the Request level
#
# 3. Update the kube-apiserver manifest at /etc/kubernetes/manifests/kube-apiserver.yaml
#    to reference the audit policy and log path. Add the necessary volume mounts.
#
# IMPORTANT: Modifying the API server manifest will restart the API server.
# Wait for it to come back before verifying.
