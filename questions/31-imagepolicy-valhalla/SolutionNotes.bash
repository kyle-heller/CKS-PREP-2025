#!/bin/bash
# Solution: ImagePolicyWebhook (valhalla)
#
# Step 1: Fix defaultAllow in admission_configuration.yaml
#   Change: defaultAllow: true  ->  defaultAllow: false
#   File: /etc/kubernetes/imgconfig/admission_configuration.yaml
#
# Step 2: Edit kube-apiserver manifest (/etc/kubernetes/manifests/kube-apiserver.yaml)
#   Add ImagePolicyWebhook to admission plugins:
#     - --enable-admission-plugins=NodeRestriction,ImagePolicyWebhook
#
#   Add admission-control-config-file flag:
#     - --admission-control-config-file=/etc/kubernetes/imgconfig/admission_configuration.yaml
#
# Step 3: Add volume mount for /etc/kubernetes/imgconfig
#   volumeMounts:
#     - mountPath: /etc/kubernetes/imgconfig
#       name: imgconfig
#       readOnly: true
#   volumes:
#     - hostPath:
#         path: /etc/kubernetes/imgconfig
#         type: DirectoryOrCreate
#       name: imgconfig
#
# Step 4: Wait for API server to restart, then test
#   kubectl apply -f /root/16/vulnerable-resource.yaml
#   # Should be denied by the webhook (or fail with no backend)
#
# Key concepts:
#   - defaultAllow: false = implicit deny (reject if webhook unreachable)
#   - defaultAllow: true = implicit allow (accept if webhook unreachable) — INSECURE
#   - ImagePolicyWebhook validates container images before pod creation
#   - The webhook endpoint (valhalla.local) would normally run an image scanner
