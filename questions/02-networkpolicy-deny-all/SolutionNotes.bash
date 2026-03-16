#!/bin/bash
# Solution: Default Deny NetworkPolicy
#
# apiVersion: networking.k8s.io/v1
# kind: NetworkPolicy
# metadata:
#   name: deny-all
#   namespace: testing
# spec:
#   podSelector: {}
#   policyTypes:
#   - Ingress
#   - Egress
#
# kubectl apply -f netpol.yaml
# kubectl get netpol -n testing
# kubectl describe netpol deny-all -n testing
#
# Verify traffic is blocked:
# kubectl exec -n testing client -- wget --timeout=2 -qO- http://web 2>&1
# Should timeout / fail
#
# Notes:
# - podSelector: {} matches ALL pods in the namespace
# - policyTypes must explicitly list both Ingress and Egress for a full deny-all
# - Without policyTypes: [Egress], pods can still make outbound connections
# - NetworkPolicies are additive — if any policy allows traffic, it's allowed
# - A deny-all policy is the baseline; add allow policies for specific flows
