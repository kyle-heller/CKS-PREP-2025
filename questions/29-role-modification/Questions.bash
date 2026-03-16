# CKS Practice — Role Modification
# Domain: Cluster Hardening (15%)
#
# In namespace security, a ServiceAccount sa-dev-1 is bound to Role role-1.
# The role currently has excessive permissions.
#
# 1. Modify Role role-1 to allow ONLY the verb "watch" on resource "services"
#    (remove all other resources and verbs)
# 2. Create a ClusterRole named role-2 that allows ONLY "update" on "namespaces"
# 3. Create a ClusterRoleBinding named role-2-binding binding role-2 to sa-dev-1
#
# Verify with:
#   kubectl auth can-i watch services --as=system:serviceaccount:security:sa-dev-1 -n security
#   kubectl auth can-i update namespaces --as=system:serviceaccount:security:sa-dev-1
