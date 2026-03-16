# CKS Practice — ServiceAccount Without Secret Access
# Domain: Cluster Hardening (15%)
#
# Task:
# 1. Create ServiceAccount backend-qa in namespace qa
# 2. Create Role no-secret-access that only allows get,list on pods (NOT secrets)
# 3. Bind the Role to backend-qa
# 4. Update existing Pod frontend to use this ServiceAccount
# 5. Verify backend-qa cannot list secrets
#
# Context:
# - Principle of least privilege: only grant the permissions a workload needs
# - The default ServiceAccount often has broader permissions than necessary
# - RBAC Roles define what resources and verbs are allowed
# - A Role that allows get,list on pods but NOT secrets limits data exposure
# - Use "kubectl auth can-i" to verify permissions from a ServiceAccount's perspective
