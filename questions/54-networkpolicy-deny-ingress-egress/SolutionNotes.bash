#!/bin/bash
# Solution: NetworkPolicy Deny All Ingress and Egress
#
# Complete /home/policy/network-policy.yaml with:
#
#   apiVersion: networking.k8s.io/v1
#   kind: NetworkPolicy
#   metadata:
#     name: deny-network
#     namespace: test
#   spec:
#     podSelector: {}
#     policyTypes:
#     - Ingress
#     - Egress
#
# Then apply:
#   kubectl apply -f /home/policy/network-policy.yaml
#
# Key concepts:
#
# This is the "default deny all" NetworkPolicy pattern. It is one of the
# most common CKS questions.
#
# How it works:
# - podSelector: {} — empty selector matches ALL pods in the namespace
# - policyTypes: [Ingress, Egress] — policy governs both directions
# - No ingress: or egress: rules — since there are no allow rules,
#   everything is denied
#
# The critical detail: simply listing a policyType without any
# corresponding rules means "deny all" for that direction.
#
# Compare to a "deny ingress only" policy:
#   policyTypes: [Ingress]  — denies all ingress, egress unaffected
#
# Compare to "allow all ingress":
#   ingress:
#   - {}                    — one rule that matches everything = allow all
#
# After applying, you can test:
#   kubectl run test -n test --image=busybox --command -- wget -qO- --timeout=2 google.com
#   # Will fail — egress is blocked
#
# To allow specific traffic later, create additional NetworkPolicies.
# NetworkPolicies are additive — if ANY policy allows the traffic, it flows.
