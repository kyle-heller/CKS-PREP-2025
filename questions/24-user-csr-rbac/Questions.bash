# CKS Practice — User CSR and RBAC
# Domain: Cluster Hardening (15%)
#
# A user john needs access to namespace john. Key and CSR are at /home/candidate/.
#
# 1. Create a CertificateSigningRequest named john-csr using john's CSR file
#    - signerName: kubernetes.io/kube-apiserver-client
#    - usage: client auth
# 2. Approve the CSR
# 3. Create Role john-role in namespace john:
#    - Resources: pods, secrets
#    - Verbs: list, get, create, delete
# 4. Create RoleBinding john-role-binding binding john-role to user john
#
# Verify with:
#   kubectl auth can-i create pods -n john --as john
#   kubectl auth can-i create deployments -n john --as john
