#!/bin/bash
# Solution: RuntimeClass with gVisor
#
# Step 1: Create RuntimeClass
# cat <<EOF | kubectl create -f -
# apiVersion: node.k8s.io/v1
# kind: RuntimeClass
# metadata:
#   name: sandboxed
# handler: runsc
# EOF
#
# Step 2: Edit each deployment
# kubectl edit deploy -n server workload1
# kubectl edit deploy -n server workload2
# kubectl edit deploy -n server workload3
# Add under spec.template.spec:
#   runtimeClassName: sandboxed
#
# Verify:
# kubectl get pods -n server -o jsonpath="{range .items[*]}{.metadata.name}{': '}{.spec.runtimeClassName}{'\n'}{end}"
