#!/bin/bash
# Solution: Istio mTLS
#
# Step 1: Enable sidecar injection
# kubectl label namespace payments istio-injection=enabled --overwrite
#
# Step 2: Create PeerAuthentication
# cat <<EOF | kubectl apply -f -
# apiVersion: security.istio.io/v1
# kind: PeerAuthentication
# metadata:
#   name: payments-mtls-strict
#   namespace: payments
# spec:
#   mtls:
#     mode: STRICT
# EOF
#
# Step 3: Restart pods if needed
# kubectl rollout restart deployment -n payments
#
# Verify:
# kubectl get peerauthentication -n payments
