# CKS Practice — ServiceAccount Token Management
# Domain: Cluster Hardening (15%)
#
# A Pod nginx-pod is running in the default namespace and uses a token by default.
#
# 1. Modify the default ServiceAccount to disable automatic token mounting.
# 2. Create a Secret of type kubernetes.io/service-account-token that references
#    the default ServiceAccount.
# 3. Edit the Pod to:
#    - Use the default ServiceAccount.
#    - Mount the token from the Secret at /var/run/secrets/kubernetes.io/serviceaccount/token.
