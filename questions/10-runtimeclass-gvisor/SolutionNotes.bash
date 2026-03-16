#!/bin/bash
# Solution: RuntimeClass with gVisor
#
# Step 1: Create RuntimeClass
#   cat <<EOF | kubectl create -f -
#   apiVersion: node.k8s.io/v1
#   kind: RuntimeClass
#   metadata:
#     name: sandboxed
#   handler: runsc
#   EOF
#
# Step 2: Edit each deployment to use the RuntimeClass
#   kubectl edit deploy -n server workload1
#   kubectl edit deploy -n server workload2
#   kubectl edit deploy -n server workload3
#
#   Add under spec.template.spec (same level as containers:):
#     runtimeClassName: sandboxed
#
#   Alternative — patch all deployments:
#   for d in workload1 workload2 workload3; do
#     kubectl patch deploy "$d" -n server --type=merge \
#       -p '{"spec":{"template":{"spec":{"runtimeClassName":"sandboxed"}}}}'
#   done
#
# Verify:
#   kubectl get deploy -n server -o jsonpath="{range .items[*]}{.metadata.name}{': '}{.spec.template.spec.runtimeClassName}{'\n'}{end}"
#   kubectl get pods -n server
#
# Notes:
#   - runtimeClassName goes under spec.template.spec in Deployments (pod template level)
#   - Pods will be recreated automatically after updating the Deployment
#   - gVisor (runsc) provides an application kernel that intercepts syscalls,
#     adding a sandbox layer between the container and the host kernel
#   - Trade-off: stronger isolation but some performance overhead and
#     not all syscalls are supported (may break some applications)
