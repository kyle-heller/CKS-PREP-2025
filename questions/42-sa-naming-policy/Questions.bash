# CKS Practice — SA Naming Policy
# Domain: Cluster Hardening (15%)
#
# Context:
#   Namespace: qa
#   A Pod named "frontend" is running using the default ServiceAccount.
#   There are also unused ServiceAccounts that should be cleaned up.
#
# Tasks:
#
# 1. Create a new ServiceAccount named "frontend-sa" in the "qa" namespace
#    with automountServiceAccountToken set to false.
#
# 2. Update the Pod "frontend" to use the new ServiceAccount "frontend-sa".
#    (You will need to delete and recreate the Pod since serviceAccountName is immutable.)
#
# 3. Clean up: delete any ServiceAccount in the "qa" namespace that is NOT
#    "default" or "frontend-sa". Remove all unused/leftover ServiceAccounts.
#
# Verify with:
#   kubectl get sa -n qa
#   kubectl get sa frontend-sa -n qa -o jsonpath='{.automountServiceAccountToken}'
#   kubectl get pod frontend -n qa -o jsonpath='{.spec.serviceAccountName}'
