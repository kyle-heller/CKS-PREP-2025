#!/bin/bash
# Solution: RuntimeClass untrusted with gVisor
#
# Step 1: Create the RuntimeClass
#
# apiVersion: node.k8s.io/v1
# kind: RuntimeClass
# metadata:
#   name: untrusted
# handler: runsc
#
#   kubectl apply -f runtimeclass.yaml
#
# Step 2: Find the worker node name
#   WORKER=$(kubectl get nodes --no-headers | grep -v control-plane | awk '{print $1}' | head -1)
#
# Step 3: Create the Pod with runtimeClassName and nodeName
#
# apiVersion: v1
# kind: Pod
# metadata:
#   name: untrusted
# spec:
#   nodeName: <worker-node>
#   runtimeClassName: untrusted
#   containers:
#   - name: untrusted
#     image: alpine:3.18
#     command: ["/bin/sh", "-c", "sleep 3600"]
#
#   kubectl apply -f pod.yaml
#
# Step 4: Capture dmesg output
#   kubectl exec untrusted -- dmesg > /opt/course/untrusted-test-dmesg
#
# Note: On KillerCoda without gVisor installed, the pod will be Pending.
# The verify script checks the spec, not the running status.
# With gVisor, dmesg output would show "Starting gVisor..." instead of
# the host kernel's dmesg, proving sandbox isolation.
