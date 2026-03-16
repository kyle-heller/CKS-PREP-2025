#!/bin/bash
# Solution: KubeSec Scanning
#
# Step 1: Scan the insecure manifest (using Docker or kubesec binary)
#   docker run -i kubesec/kubesec:512c5e0 scan /dev/stdin < /home/candidate/kubesec-test.yaml
#   # or: kubesec scan /home/candidate/kubesec-test.yaml
#
# Step 2: Apply all 5 security fixes to kubesec-test.yaml
#
# apiVersion: v1
# kind: Pod
# metadata:
#   name: kubesec-demo
# spec:
#   containers:
#     - name: kubesec-demo
#       image: gcr.io/google-samples/node-hello:1.0
#       securityContext:
#         runAsUser: 1000
#         runAsNonRoot: true
#         allowPrivilegeEscalation: false
#         readOnlyRootFilesystem: true
#         capabilities:
#           drop:
#             - ALL
#
# Step 3: Re-scan to verify score >= 4
#   docker run -i kubesec/kubesec:512c5e0 scan /dev/stdin < /home/candidate/kubesec-test.yaml
#
# Each fix adds points:
#   +1  runAsUser (non-root UID)
#   +1  runAsNonRoot: true
#   +1  allowPrivilegeEscalation: false
#   +1  readOnlyRootFilesystem: true
#   +1  capabilities.drop: ALL
#   Total: 5 points
