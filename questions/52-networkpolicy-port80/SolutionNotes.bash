#!/bin/bash
# Solution: NetworkPolicy Allow Port 80 Ingress
#
# Apply this NetworkPolicy:
#
#   apiVersion: networking.k8s.io/v1
#   kind: NetworkPolicy
#   metadata:
#     name: allow-np
#     namespace: staging
#   spec:
#     podSelector: {}
#     policyTypes:
#     - Ingress
#     ingress:
#     - from:
#       - podSelector: {}
#       ports:
#       - protocol: TCP
#         port: 80
#
# Key concepts:
#
# podSelector: {} — empty selector matches ALL pods in the namespace.
# This means the policy applies to every pod in staging.
#
# ingress.from.podSelector: {} — allows traffic from any pod in the
# SAME namespace. This is NOT the same as allowing all traffic — pods
# from other namespaces are still blocked.
#
# If you wanted to allow from a SPECIFIC namespace, you would use
# namespaceSelector instead of (or in addition to) podSelector.
#
# ports.port: 80 with protocol: TCP — restricts allowed ingress to
# only TCP port 80. All other ports are denied.
#
# policyTypes: [Ingress] — this policy only governs ingress rules.
# Egress is unaffected (all egress still allowed by default).
#
# Testing:
#   kubectl exec -n staging test-pod -- wget -qO- --timeout=2 nginx:80
#   # Should succeed (same namespace, port 80)
#
#   kubectl exec -n staging test-pod -- wget -qO- --timeout=2 nginx:443
#   # Should fail (port 443 not allowed)
