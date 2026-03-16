# CKS Practice — User CSR and RBAC
# Domain: Cluster Hardening (15%)
#
# Create user john with CSR. Approve it.
# Create Role john-role in namespace john: list,get,create,delete on pods and secrets.
# Create RoleBinding john-role-binding.
# Verify with kubectl auth can-i.
