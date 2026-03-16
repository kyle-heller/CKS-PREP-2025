# CKS Practice — NetworkPolicy: Allow Port 80 Ingress
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# In the staging namespace:
#
# Create a NetworkPolicy named allow-np that:
#   1. Applies to all pods in the staging namespace (empty podSelector)
#   2. Allows ingress traffic from pods in the same namespace only
#   3. Restricts ingress to TCP port 80 only
#   4. policyTypes: Ingress
#
# The policy should:
#   - Use podSelector: {} (match all pods)
#   - Have an ingress rule with a from clause using podSelector: {} (same namespace)
#   - Specify port 80 protocol TCP
#
# Namespace: staging
