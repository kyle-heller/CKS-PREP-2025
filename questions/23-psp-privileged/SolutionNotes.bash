#!/bin/bash
# Solution: PodSecurityPolicy (Deprecated — manifest exercise)
#
# NOTE: PSP was removed in Kubernetes 1.25. This is a knowledge exercise.
# Replaced by Pod Security Admission (PSA) in modern K8s.
#
# Write the following to /home/candidate/23/psp-solution.yaml:
#
# --- PSP Resource ---
# apiVersion: policy/v1beta1
# kind: PodSecurityPolicy
# metadata:
#   name: prevent-psp-policy
# spec:
#   privileged: false
#   allowPrivilegeEscalation: false
#   requiredDropCapabilities: ["ALL"]
#   volumes:
#     - configMap
#     - emptyDir
#     - projected
#     - secret
#     - downwardAPI
#     - persistentVolumeClaim
#   runAsUser:
#     rule: MustRunAsNonRoot
#   seLinux:
#     rule: RunAsAny
#   supplementalGroups:
#     rule: RunAsAny
#   fsGroup:
#     rule: RunAsAny
#   readOnlyRootFilesystem: true
#
# --- Commands (included as comments or script) ---
# kubectl create clusterrole restrict-access-role \
#   --verb=use \
#   --resource=podsecuritypolicies.policy \
#   --resource-name=prevent-psp-policy
#
# kubectl create serviceaccount psp-restrict-sa -n staging
#
# kubectl create clusterrolebinding restrict-access-bind \
#   --clusterrole=restrict-access-role \
#   --serviceaccount=staging:psp-restrict-sa
