#!/bin/bash
# Solution: Istio mTLS
#
# Step 1: Label the namespace for sidecar injection
#   kubectl label namespace payments istio-injection=enabled --overwrite
#
#   This tells Istio's mutating webhook to automatically inject the
#   Envoy sidecar proxy into every Pod created in this namespace.
#
# Step 2: Create PeerAuthentication resource
#   cat <<EOF | kubectl apply -f -
#   apiVersion: security.istio.io/v1
#   kind: PeerAuthentication
#   metadata:
#     name: payments-mtls-strict
#     namespace: payments
#   spec:
#     mtls:
#       mode: STRICT
#   EOF
#
# Step 3: Restart existing pods (so sidecars get injected)
#   kubectl rollout restart deployment -n payments
#
# Verify:
#   kubectl get ns payments --show-labels
#   kubectl get peerauthentication -n payments
#
# Notes:
#   - STRICT mode rejects any unencrypted traffic — all Pods must have sidecars
#   - PERMISSIVE mode allows both plain and mTLS traffic (useful during migration)
#   - Namespace-level PeerAuthentication applies to all workloads in the namespace
#   - Workload-level PeerAuthentication can override namespace policy for specific services
#   - If Pods were created before the injection label, restart them to inject sidecars
