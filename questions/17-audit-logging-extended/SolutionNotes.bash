#!/bin/bash
# Solution: Audit Logging Extended
#
# apiVersion: audit.k8s.io/v1
# kind: Policy
# omitStages: ["RequestReceived"]
# rules:
#   - level: RequestResponse
#     resources: [{group: "", resources: ["namespaces"]}]
#   - level: Request
#     namespaces: ["kube-system"]
#     resources: [{group: "", resources: ["secrets"]}]
#   - level: Request
#     resources: [{group: ""}, {group: "extensions"}]
#   - level: Metadata
#     resources: [{group: "", resources: ["pods/portforward", "services/proxy"]}]
#   - level: Metadata
#
# kube-apiserver flags:
#   --audit-log-maxage=12 --audit-log-maxbackup=8 --audit-log-maxsize=200
