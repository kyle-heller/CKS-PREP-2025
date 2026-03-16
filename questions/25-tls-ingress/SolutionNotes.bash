#!/bin/bash
# Solution: TLS Ingress
#
# Step 1: Create TLS Secret
#   kubectl create secret tls bingo-tls \
#     --cert=/home/candidate/bingo.crt \
#     --key=/home/candidate/bingo.key \
#     -n testing
#
# Step 2: Run nginx pod and expose as Service
#   kubectl run nginx-pod -n testing --image=nginx --expose=true --port=80
#
# Step 3: Create Ingress with TLS and redirect
#
# apiVersion: networking.k8s.io/v1
# kind: Ingress
# metadata:
#   name: bingo-com
#   namespace: testing
#   annotations:
#     nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
#     nginx.ingress.kubernetes.io/ssl-redirect: "true"
# spec:
#   rules:
#   - host: bingo.com
#     http:
#       paths:
#       - path: /
#         pathType: Prefix
#         backend:
#           service:
#             name: nginx-pod
#             port:
#               number: 80
#   tls:
#   - hosts:
#     - bingo.com
#     secretName: bingo-tls
#
#   kubectl apply -f ingress.yaml
#
# Note: No Ingress controller on KillerCoda — verify resource spec only.
# On the real exam, an Ingress controller will be available.
