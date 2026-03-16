#!/bin/bash
# Solution: Audit Logging (Extended Policy)
#
# Step 1: Write the audit policy file at /etc/audit/audit-policy.yaml
#
# apiVersion: audit.k8s.io/v1
# kind: Policy
# omitStages:
#   - "RequestReceived"
# rules:
#   - level: RequestResponse
#     resources:
#       - group: ""
#         resources: ["namespaces"]
#   - level: Request
#     namespaces: ["kube-system"]
#     resources:
#       - group: ""
#         resources: ["secrets"]
#   - level: Request
#     resources:
#       - group: ""
#       - group: "extensions"
#   - level: Metadata
#     resources:
#       - group: ""
#         resources: ["pods/portforward", "services/proxy"]
#   - level: Metadata
#
# Step 2: Edit kube-apiserver manifest (/etc/kubernetes/manifests/kube-apiserver.yaml)
#   Add these flags:
#     - --audit-policy-file=/etc/audit/audit-policy.yaml
#     - --audit-log-path=/var/log/kubernetes-logs.log
#     - --audit-log-maxage=12
#     - --audit-log-maxbackup=8
#     - --audit-log-maxsize=200
#
# Step 3: Add volume mounts (if not already present)
#   volumeMounts:
#     - mountPath: /etc/audit/audit-policy.yaml
#       name: audit
#       readOnly: true
#     - mountPath: /var/log
#       name: audit-log
#       readOnly: false
#   volumes:
#     - hostPath:
#         path: /etc/audit/audit-policy.yaml
#         type: File
#       name: audit
#     - hostPath:
#         path: /var/log
#         type: DirectoryOrCreate
#       name: audit-log
#
# Step 4: Wait for API server to restart
#   kubectl get nodes   # poll until responsive
#
# Key concepts:
#   - omitStages: skip logging at RequestReceived stage (reduce noise)
#   - Rules are evaluated in order; first match wins
#   - RequestResponse: logs request + response bodies (most verbose)
#   - Request: logs request body only
#   - Metadata: logs metadata only (user, timestamp, resource, verb)
#   - None: don't log
