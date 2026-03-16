# CKS Practice — NetworkPolicy: Deny All Ingress and Egress
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# In the test namespace:
#
# A skeleton NetworkPolicy file exists at /home/policy/network-policy.yaml.
# Complete it to create a NetworkPolicy named deny-network that:
#
#   1. Applies to all pods in the test namespace (empty podSelector)
#   2. Blocks ALL ingress traffic
#   3. Blocks ALL egress traffic
#   4. policyTypes must include both Ingress and Egress
#
# After completing the file, apply it:
#   kubectl apply -f /home/policy/network-policy.yaml
#
# Namespace: test
