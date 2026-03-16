# CKS Practice — Audit Logging
# Domain: Monitoring, Logging and Runtime Security (20%)
#
# Enable Kubernetes audit logging with custom retention and policy rules:
#
# 1. Store audit logs at /var/log/kubernetes-logs.log.
# 2. Retain logs for 5 days, maximum 10 old files, 100 MB per file.
# 3. Extend audit policy to:
#    - Log CronJob changes at RequestResponse level.
#    - Log request bodies for deployments in kube-system namespace.
#    - Log all other core and extensions resources at Request level.
#    - Exclude watch requests by system:kube-proxy on endpoints or services.
