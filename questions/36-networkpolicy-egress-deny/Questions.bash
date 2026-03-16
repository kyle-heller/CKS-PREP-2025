# CKS Practice — Default Deny Egress NetworkPolicy
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# Task:
# 1. In namespace testing, create a NetworkPolicy named "default-deny"
# 2. It must block all Egress traffic from all pods
# 3. policyTypes must include Egress
# 4. podSelector must be empty ({}) to match all pods
#
# Context:
# - Default deny policies are a foundational network security control
# - An empty podSelector {} selects ALL pods in the namespace
# - policyTypes: ["Egress"] with no egress rules blocks all outbound traffic
# - This prevents data exfiltration and lateral movement from compromised pods
# - DNS resolution (UDP/TCP 53) will also be blocked unless explicitly allowed
