#!/bin/bash
# Solution: Audit Logging
#
# Step 1: Edit /etc/audit/audit-policy.yaml
#
# apiVersion: audit.k8s.io/v1
# kind: Policy
# rules:
#   - level: RequestResponse
#     resources:
#       - group: "batch"
#         resources: ["cronjobs"]
#   - level: Request
#     namespaces: ["kube-system"]
#     resources:
#       - group: "apps"
#         resources: ["deployments"]
#   - level: Request
#     resources:
#       - group: ""
#       - group: "extensions"
#   - level: None
#     users: ["system:kube-proxy"]
#     verbs: ["watch"]
#     resources:
#       - group: ""
#         resources: ["endpoints", "services"]
#
# Step 2: Edit /etc/kubernetes/manifests/kube-apiserver.yaml
#   Add flags:
#     - --audit-policy-file=/etc/audit/audit-policy.yaml
#     - --audit-log-path=/var/log/kubernetes-logs.log
#     - --audit-log-maxage=5
#     - --audit-log-maxbackup=10
#     - --audit-log-maxsize=100
#
#   Add volumeMounts + volumes for:
#     /etc/audit/audit-policy.yaml (type: File)
#     /var/log/ (type: DirectoryOrCreate)
#
# Step 3: Wait for API server restart, then verify:
#   tail -f /var/log/kubernetes-logs.log
