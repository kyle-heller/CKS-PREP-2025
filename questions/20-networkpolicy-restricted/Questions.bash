# CKS Practice — Restricted NetworkPolicy
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# Create restricted-policy in dev-team namespace allowing ingress to products-service only from:
# - Pods in the same namespace dev-team.
# - Pods with label environment=testing in any namespace.
