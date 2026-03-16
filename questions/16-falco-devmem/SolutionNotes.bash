#!/bin/bash
# Solution: Falco — Detect /dev/mem Access
#
# Custom Falco rule (save as rule.yaml):
# - rule: read write below /dev/mem
#   desc: An attempt to read or write to /dev/mem
#   condition: >
#     ((evt.is_open_read=true or evt.is_open_write=true) and fd.name contains /dev/mem)
#   output: "Process %proc.name accessed /dev/mem (pod_name=%k8s.pod.name namespace=%k8s.ns.name)"
#   priority: WARNING
#   tags: [security]
#
# Run: falco -r rule.yaml | grep -i 'dev/mem'
#
# From output, identify the Pod -> Deployment
# kubectl scale deployment mem-hacker --replicas=0 -n default
