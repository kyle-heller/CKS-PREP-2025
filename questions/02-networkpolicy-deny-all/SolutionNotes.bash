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
