# CKS Practice — Restricted NetworkPolicy
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# In namespace dev-team, create a NetworkPolicy named restricted-policy that:
#
# 1. Applies to pods with label environment=dev (products-service)
# 2. Allows ingress traffic ONLY from:
#    a) Any pod in the same namespace (dev-team)
#    b) Pods with label environment=testing from ANY namespace
# 3. Denies all other ingress traffic
#
# Verify with: kubectl describe netpol -n dev-team restricted-policy
