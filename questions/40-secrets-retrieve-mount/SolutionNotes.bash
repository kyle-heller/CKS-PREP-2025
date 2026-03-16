#!/bin/bash
# Solution: Secrets — Retrieve and Mount
#
# Step 1: Retrieve and decode the existing secret
#   kubectl get secret dev-token -n dev -o jsonpath='{.data.token}' | base64 -d > /home/candidate/ca.crt
#
#   Verify:
#     cat /home/candidate/ca.crt
#     # Should show decoded certificate content
#
# Step 2: Create the new secret in app namespace
#   kubectl create secret generic app-config-secret -n app \
#     --from-literal=APP_USER=appadmin \
#     --from-literal=APP_PASS=Sup3rS3cret
#
#   Verify:
#     kubectl get secret app-config-secret -n app -o jsonpath='{.data.APP_USER}' | base64 -d
#     # appadmin
#
# Step 3: Create the Pod with the secret mounted as a volume
#
#   apiVersion: v1
#   kind: Pod
#   metadata:
#     name: app-pod
#     namespace: app
#   spec:
#     containers:
#     - name: app-container
#       image: nginx
#       volumeMounts:
#       - name: app-config-vol
#         mountPath: /etc/app-config
#         readOnly: true
#     volumes:
#     - name: app-config-vol
#       secret:
#         secretName: app-config-secret
#
#   kubectl apply -f app-pod.yaml
#
#   Verify:
#     kubectl exec app-pod -n app -- ls /etc/app-config
#     # APP_USER  APP_PASS
#     kubectl exec app-pod -n app -- cat /etc/app-config/APP_USER
#     # appadmin
#
# Notes:
#   - Kubernetes secrets are base64-encoded (not encrypted) by default
#   - kubectl get secret -o jsonpath returns the base64-encoded value;
#     pipe through `base64 -d` to decode
#   - When mounted as a volume, each key in the secret becomes a file
#     in the mount directory (e.g., /etc/app-config/APP_USER)
#   - The file contents are automatically decoded (plain text)
#   - readOnly: true is a best practice — prevents the container from
#     accidentally modifying the mounted secret files
#   - Alternative to volume mount: use envFrom to inject secrets as
#     environment variables (but volume mounts are more secure —
#     env vars can leak in logs, process listings, and crash dumps)
