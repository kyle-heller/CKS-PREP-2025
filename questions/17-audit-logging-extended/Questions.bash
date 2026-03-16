# CKS Practice — Audit Logging (Extended Policy)
# Domain: Monitoring, Logging and Runtime Security (20%)
#
# Store audit logs at /var/log/kubernetes-logs.log.
# Retain 12 days, max 8 files, rotate at 200MB.
# Extend policy:
#   - Log namespace changes at RequestResponse.
#   - Log secret changes in kube-system at Request.
#   - Log core and extensions at Request.
#   - Log pods/portforward, services/proxy at Metadata.
#   - Omit RequestReceived stage.
#   - Default all others at Metadata.
