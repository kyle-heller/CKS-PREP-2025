# CKS Practice — CiliumNetworkPolicy (ICMP Deny + mTLS)
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# In namespace team-dev, create two CiliumNetworkPolicies:
#
# 1. Policy team-dev:
#    - Select pods with role=stuff
#    - Deny outgoing ICMP (ping) to pods with role=backend
#    - Use egressDeny with icmps field
#
# 2. Policy team-dev-2:
#    - Select pods with role=database
#    - Allow ingress from pods with role=api-service
#    - Require mutual authentication (authentication.mode: "required")
#
# Apply both policies and verify with:
#   kubectl get cnp -n team-dev
