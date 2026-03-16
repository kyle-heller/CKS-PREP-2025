#!/bin/bash
# Solution: PSP Prevent Privileged (Manifest-Only)
#
# Write the following to /home/candidate/53/psp-solution.yaml:
#
# ---
# apiVersion: policy/v1beta1
# kind: PodSecurityPolicy
# metadata:
#   name: prevent-privileged-policy
# spec:
#   privileged: false
#   allowPrivilegeEscalation: false
#   runAsUser:
#     rule: RunAsAny
#   fsGroup:
#     rule: RunAsAny
#   seLinux:
#     rule: RunAsAny
#   supplementalGroups:
#     rule: RunAsAny
#   volumes:
#   - 'configMap'
#   - 'emptyDir'
#   - 'secret'
# ---
# apiVersion: rbac.authorization.k8s.io/v1
# kind: ClusterRole
# metadata:
#   name: prevent-role
# rules:
# - apiGroups: ["policy"]
#   resources: ["podsecuritypolicies"]
#   verbs: ["use"]
#   resourceNames: ["prevent-privileged-policy"]
# ---
# apiVersion: v1
# kind: ServiceAccount
# metadata:
#   name: psp-sa
#   namespace: default
# ---
# apiVersion: rbac.authorization.k8s.io/v1
# kind: ClusterRoleBinding
# metadata:
#   name: prevent-role-binding
# roleRef:
#   apiGroup: rbac.authorization.k8s.io
#   kind: ClusterRole
#   name: prevent-role
# subjects:
# - kind: ServiceAccount
#   name: psp-sa
#   namespace: default
#
# Key concepts:
#
# - PSP was removed in K8s 1.25 but the CKS exam may still test knowledge
#   of the concepts. The attributes map directly to securityContext and
#   Pod Security Standards (PSS).
#
# - privileged: false — prevents pods from running in privileged mode
# - allowPrivilegeEscalation: false — prevents setuid binaries from gaining
#   elevated privileges
# - The ClusterRole needs the "use" verb on podsecuritypolicies resource
#   (not get/list/watch — "use" is a special PSP verb)
# - The ClusterRoleBinding ties the SA to the ClusterRole, meaning pods
#   using psp-sa must comply with prevent-privileged-policy
#
# Modern equivalent: Pod Security Admission (PSA) with enforce: restricted
