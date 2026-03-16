#!/bin/bash
# Solution: ImagePolicyWebhook
#
# Step 1: Fix admission_configuration.yaml
#   Change: defaultAllow: true  ->  defaultAllow: false
#
# Step 2: Edit kube-apiserver manifest
#   - --enable-admission-plugins=NodeRestriction,ImagePolicyWebhook
#   - --admission-control-config-file=/etc/kubernetes/confcontrol/admission_configuration.yaml
#
#   Add volume mount for /etc/kubernetes/confcontrol
#
# Step 3: Test
#   kubectl run pod-latest --image=nginx:latest
#   # Should be denied
