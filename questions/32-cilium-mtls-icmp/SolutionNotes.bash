#!/bin/bash
# Solution: CiliumNetworkPolicy — ICMP Deny + mTLS
#
# Policy 1: team-dev — Deny outgoing ICMP from stuff to backend
#
# apiVersion: cilium.io/v2
# kind: CiliumNetworkPolicy
# metadata:
#   name: team-dev
#   namespace: team-dev
# spec:
#   endpointSelector:
#     matchLabels:
#       role: stuff
#   egressDeny:
#     - icmps:
#         - fields:
#             - type: 8
#               family: IPv4
#       toPorts: []
#       toEndpoints:
#         - matchLabels:
#             role: backend
#
# Policy 2: team-dev-2 — Enable Mutual Authentication
#
# apiVersion: cilium.io/v2
# kind: CiliumNetworkPolicy
# metadata:
#   name: team-dev-2
#   namespace: team-dev
# spec:
#   endpointSelector:
#     matchLabels:
#       role: database
#   ingress:
#     - fromEndpoints:
#         - matchLabels:
#             role: api-service
#       authentication:
#         mode: "required"
#
# kubectl apply -f team-dev-cnp.yaml
# kubectl apply -f team-dev-2-cnp.yaml
#
# Key concepts:
#   - CiliumNetworkPolicy extends K8s NetworkPolicy with L7 + ICMP support
#   - egressDeny with icmps: explicitly blocks ICMP (ping) traffic
#   - ICMP type 8 = Echo Request (ping)
#   - authentication.mode: "required" enforces mutual TLS between endpoints
#   - Cilium Mutual Authentication uses SPIFFE identities
