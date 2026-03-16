#!/bin/bash
# Solution: Pod Security — Enforce Restricted
#
# Step 1: Label the namespace with restricted enforcement
#   kubectl label ns team-blue pod-security.kubernetes.io/enforce=restricted
#
# Step 2: Verify the label
#   kubectl get ns team-blue --show-labels
#
# Step 3: Delete one of the Pods from the Deployment
#   POD=$(kubectl get pods -n team-blue -l app=privileged-runner -o name | head -1)
#   kubectl delete $POD -n team-blue
#
#   The ReplicaSet will try to recreate the Pod but it will be rejected
#   by the Pod Security Admission controller because:
#   - privileged: true is forbidden under restricted
#   - runAsUser: 0 (root) is forbidden under restricted
#
# Step 4: Find the ReplicaSet name
#   kubectl get rs -n team-blue
#
# Step 5: Capture FailedCreate events to the output file
#   kubectl describe rs -n team-blue -l app=privileged-runner > /opt/candidate/16/logs
#
#   OR use events directly:
#   kubectl get events -n team-blue --field-selector reason=FailedCreate > /opt/candidate/16/logs
#
# Key concepts:
# - Pod Security Admission (PSA) replaced PodSecurityPolicy in K8s 1.25+
# - Three profiles: privileged, baseline, restricted
# - Three modes: enforce (reject), audit (log), warn (show warnings)
# - Labels: pod-security.kubernetes.io/{enforce|audit|warn}={privileged|baseline|restricted}
# - Existing Pods are NOT affected -- only new Pod creation is checked
# - That is why you must delete a Pod to trigger the ReplicaSet to recreate (and fail)
# - The restricted profile forbids: privileged, hostPID/Network/IPC, root, capabilities, etc.
