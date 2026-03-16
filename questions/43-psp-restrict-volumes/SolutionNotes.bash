#!/bin/bash
# Solution: PSP Restrict Volumes (Manifest-Only)
#
# NOTE: PodSecurityPolicy was removed in Kubernetes 1.25.
# Replaced by Pod Security Admission (PSA) in modern K8s.
# This is a knowledge/manifest exercise for CKS exam prep.
#
# Write the following to /home/candidate/43/psp-solution.yaml:
#
# cat > /home/candidate/43/psp-solution.yaml <<'EOF'
# apiVersion: policy/v1beta1
# kind: PodSecurityPolicy
# metadata:
#   name: prevent-volume-policy
# spec:
#   privileged: false
#   allowPrivilegeEscalation: false
#   volumes:
#     - persistentVolumeClaim
#   runAsUser:
#     rule: MustRunAsNonRoot
#   seLinux:
#     rule: RunAsAny
#   supplementalGroups:
#     rule: RunAsAny
#   fsGroup:
#     rule: RunAsAny
# ---
# apiVersion: v1
# kind: ServiceAccount
# metadata:
#   name: psp-sa
#   namespace: restricted
# ---
# apiVersion: rbac.authorization.k8s.io/v1
# kind: ClusterRole
# metadata:
#   name: psp-role
# rules:
# - apiGroups: ["policy"]
#   resources: ["podsecuritypolicies"]
#   resourceNames: ["prevent-volume-policy"]
#   verbs: ["use"]
# ---
# apiVersion: rbac.authorization.k8s.io/v1
# kind: ClusterRoleBinding
# metadata:
#   name: psp-role-binding
# subjects:
# - kind: ServiceAccount
#   name: psp-sa
#   namespace: restricted
# roleRef:
#   kind: ClusterRole
#   name: psp-role
#   apiGroup: rbac.authorization.k8s.io
# EOF
#
# Key points:
#   - The volumes list ONLY contains "persistentVolumeClaim"
#     This means Pods under this PSP can only use PVC-backed volumes.
#     No hostPath, emptyDir, secret, configMap, etc.
#   - privileged: false prevents containers from running in privileged mode
#   - allowPrivilegeEscalation: false prevents setuid binaries from gaining root
#   - MustRunAsNonRoot requires a non-zero runAsUser or the image must use non-root
#   - The ClusterRole uses verb "use" on podsecuritypolicies (apiGroup: policy)
#   - resourceNames scopes the ClusterRole to this specific PSP only
#   - The ClusterRoleBinding binds psp-sa in the restricted namespace
#
# Modern replacement (Pod Security Admission):
#   kubectl label namespace restricted \
#     pod-security.kubernetes.io/enforce=restricted \
#     pod-security.kubernetes.io/warn=restricted
