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
#
# Test the CronJob rule:
#   kubectl create cronjob testjob --image=busybox --schedule="*/1 * * * *" -- /bin/sh -c 'date'
#   cat /var/log/kubernetes-logs.log | grep cronjob
#
# Notes:
# - Audit levels: None < Metadata < Request < RequestResponse
# - Rules are evaluated in order — first match wins
# - The kube-proxy exclusion rule must come BEFORE the catch-all core/extensions rule
# - Volume mounts are needed for BOTH the policy file AND the log directory
# - If the API server fails to start, check: missing volumes, bad YAML indentation,
#   or typos in the policy file path
