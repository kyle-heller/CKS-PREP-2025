#!/bin/bash
# Solution: NetworkPolicy — Restricted Ingress
#
# Step 1: Create the NetworkPolicy YAML
#
# apiVersion: networking.k8s.io/v1
# kind: NetworkPolicy
# metadata:
#   name: restricted-policy
#   namespace: dev-team
# spec:
#   podSelector:
#     matchLabels:
#       environment: dev
#   policyTypes:
#   - Ingress
#   ingress:
#     - from:
#         - podSelector: {}          # All pods in dev-team namespace
#     - from:
#         - namespaceSelector: {}    # Any namespace...
#           podSelector:
#             matchLabels:
#               environment: testing  # ...with this label
#
# Step 2: Apply
#   kubectl apply -f netpol.yaml
#
# Step 3: Verify
#   kubectl describe netpol -n dev-team restricted-policy
#
# Key concepts:
#   - Two separate "- from:" entries = OR logic (either rule allows traffic)
#   - Within a single "from:" entry, namespaceSelector + podSelector = AND logic
#   - podSelector: {} with no namespaceSelector = same namespace only
#   - namespaceSelector: {} = all namespaces
