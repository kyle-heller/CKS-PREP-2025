#!/bin/bash
# Solution: Falco — Detect /dev/mem Access
#
# Step 1: Complete the Falco rule (/home/candidate/falco-rule.yaml)
#
#   - rule: detect dev mem access
#     desc: An attempt to read or write to /dev/mem directory
#     condition: >
#       ((evt.is_open_read=true or evt.is_open_write=true) and fd.name contains /dev/mem)
#     output: >
#       Process %proc.name accessed /dev/mem
#       (command=%proc.cmdline user=%user.name container=%container.id
#       image=%container.image.repository pod_name=%k8s.pod.name
#       namespace=%k8s.ns.name)
#     priority: WARNING
#     tags: [security]
#
# Step 2: Run Falco to identify the Pod (if Falco is installed)
#   falco -r /home/candidate/falco-rule.yaml
#   # Output will show the pod name and namespace
#
# Step 3: Scale the deployment to 0
#   kubectl scale deployment mem-hacker --replicas=0 -n default
#
# Verify:
#   kubectl get deploy mem-hacker -n default
#   # READY 0/0
#
# Notes:
#   - evt.is_open_read=true matches syscalls like open(), openat() with read flag
#   - evt.is_open_write=true matches same syscalls with write flag
#   - Common mistake: using evt.type=read instead of evt.is_open_read=true
#     evt.type=read matches the read() syscall, NOT the open-for-reading action
#   - fd.name contains /dev/mem matches any file path containing /dev/mem
#   - Falco rules use Sysdig filter syntax (not regex)
#   - The priority field determines log level: EMERGENCY > ALERT > CRITICAL >
#     ERROR > WARNING > NOTICE > INFORMATIONAL > DEBUG
