#!/bin/bash
# Solution: Projected ServiceAccount Token
#
# Step 1: Disable automount on default ServiceAccount
#   kubectl patch sa default -p '{"automountServiceAccountToken": false}'
#
# Step 2: Delete existing pod (must recreate with new volume spec)
#   kubectl delete pod token-demo --grace-period=0 --force
#
# Step 3: Create Pod with projected serviceAccountToken volume
#
# apiVersion: v1
# kind: Pod
# metadata:
#   name: token-demo
#   namespace: default
# spec:
#   serviceAccountName: default
#   containers:
#   - name: nginx
#     image: nginx
#     volumeMounts:
#     - name: token-vol
#       mountPath: /var/run/secrets/tokens
#       readOnly: true
#   volumes:
#   - name: token-vol
#     projected:
#       sources:
#       - serviceAccountToken:
#           path: token.jwt
#           expirationSeconds: 600
#           audience: https://kubernetes.default.svc.cluster.local
#
#   kubectl apply -f token-demo.yaml
#
# Step 4: Verify
#   kubectl exec token-demo -- cat /var/run/secrets/tokens/token.jwt
#
# Key concepts:
#   - Projected volumes combine multiple sources into one mount
#   - serviceAccountToken source creates a bound, time-limited token
#   - expirationSeconds: kubelet rotates the token before expiry
#   - audience: who the token is intended for (OIDC audience claim)
#   - automountServiceAccountToken: false prevents the default auto-mounted token
