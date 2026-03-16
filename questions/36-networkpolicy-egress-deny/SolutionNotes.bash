#!/bin/bash
# CKS Practice — Default Deny Egress NetworkPolicy — Solution Notes
# Domain: Minimize Microservice Vulnerabilities (20%)

# Step 1: Create the default-deny NetworkPolicy
# kubectl apply -f - <<'EOF'
# apiVersion: networking.k8s.io/v1
# kind: NetworkPolicy
# metadata:
#   name: default-deny
#   namespace: testing
# spec:
#   podSelector: {}
#   policyTypes:
#   - Egress
# EOF
#
# This blocks ALL egress from ALL pods in the testing namespace.
# podSelector: {} with no match labels selects every pod.
# policyTypes: [Egress] with no egress[] rules = deny all outbound.

# Optional: Allow DNS egress (so pods can still resolve names)
# If the question allows it, you can add a DNS exception:
#
# kubectl apply -f - <<'EOF'
# apiVersion: networking.k8s.io/v1
# kind: NetworkPolicy
# metadata:
#   name: default-deny
#   namespace: testing
# spec:
#   podSelector: {}
#   policyTypes:
#   - Egress
#   egress:
#   - to:
#     - namespaceSelector: {}
#     ports:
#     - protocol: UDP
#       port: 53
#     - protocol: TCP
#       port: 53
# EOF
#
# This allows only DNS traffic (port 53) and blocks everything else.

# Step 2: Verify the policy
# kubectl get networkpolicy default-deny -n testing -o yaml
# kubectl describe networkpolicy default-deny -n testing

# Step 3: Test that egress is blocked
# kubectl exec -n testing test-client -- wget --timeout=3 -q -O- http://web-app 2>&1
# Expected: connection timeout (egress blocked)

# Key concepts:
# - NetworkPolicy is additive — multiple policies are OR'd together
# - An empty podSelector {} matches ALL pods in the namespace
# - policyTypes: [Egress] without egress rules = deny all outbound
# - policyTypes: [Ingress] without ingress rules = deny all inbound
# - For full isolation, include both Ingress and Egress in policyTypes
# - NetworkPolicy requires a CNI plugin that supports it (Calico, Cilium, etc.)
# - Without any NetworkPolicy, all traffic is allowed by default
