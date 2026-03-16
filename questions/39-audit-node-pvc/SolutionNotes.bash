#!/bin/bash
# Solution: Audit — Node and PVC Changes
#
# Step 1: Write the audit policy at /etc/audit/audit-policy.yaml
#
#   apiVersion: audit.k8s.io/v1
#   kind: Policy
#   rules:
#     # Log Node changes at RequestResponse level (full request + response bodies)
#     - level: RequestResponse
#       resources:
#         - group: ""
#           resources: ["nodes"]
#
#     # Log PVC changes in frontend namespace at Request level (request body only)
#     - level: Request
#       resources:
#         - group: ""
#           resources: ["persistentvolumeclaims"]
#       namespaces: ["frontend"]
#
# Step 2: Edit the API server manifest
#   vi /etc/kubernetes/manifests/kube-apiserver.yaml
#
#   Add these flags to the kube-apiserver command:
#     - --audit-policy-file=/etc/audit/audit-policy.yaml
#     - --audit-log-path=/var/log/kubernetes-logs.log
#     - --audit-log-maxage=5
#     - --audit-log-maxbackup=10
#
#   Add volume mount for the audit policy file:
#     volumeMounts:
#     - name: audit-policy
#       mountPath: /etc/audit/audit-policy.yaml
#       readOnly: true
#     - name: audit-log
#       mountPath: /var/log/kubernetes-logs.log
#       readOnly: false
#
#   Add corresponding volumes:
#     volumes:
#     - name: audit-policy
#       hostPath:
#         path: /etc/audit/audit-policy.yaml
#         type: File
#     - name: audit-log
#       hostPath:
#         path: /var/log/kubernetes-logs.log
#         type: FileOrCreate
#
# Step 3: Wait for the API server to restart (~30-60 seconds)
#   watch crictl ps   # or: kubectl get pods -n kube-system
#
# Verify:
#   kubectl get nodes              # triggers a node-related API call
#   cat /var/log/kubernetes-logs.log | tail -5
#   # Should see audit log entries
#
# Notes:
#   - Audit policy rules are evaluated top-to-bottom; first match wins
#   - Four audit levels: None < Metadata < Request < RequestResponse
#     None:             no logging
#     Metadata:         log request metadata (user, timestamp, resource, verb)
#     Request:          log metadata + request body
#     RequestResponse:  log metadata + request body + response body
#   - The audit-policy-file path in the API server flag must match the
#     mountPath inside the container (not the host path)
#   - Always mount the policy as readOnly: true
#   - The log file path must also be volume-mounted so the API server
#     container can write to it
#   - After saving the manifest, the kubelet detects the change and
#     restarts the kube-apiserver static pod automatically
#   - Common mistake: forgetting the volume mounts — the API server
#     will crash-loop if it cannot find the policy file at the mounted path
