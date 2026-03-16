# CKS Practice — PSP: Prevent Privileged (Manifest-Only)
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# NOTE: PSP API was removed in Kubernetes 1.25+.
# This is a MANIFEST-ONLY exercise — write YAML to a file, do not apply.
#
# Write a multi-document YAML file to /home/candidate/53/psp-solution.yaml
# containing ALL of the following resources:
#
# 1. PodSecurityPolicy: prevent-privileged-policy
#    - privileged: false
#    - allowPrivilegeEscalation: false
#    - runAsUser rule: RunAsAny
#    - fsGroup rule: RunAsAny
#    - volumes: ['configMap', 'emptyDir', 'secret']
#
# 2. ClusterRole: prevent-role
#    - apiGroups: ["policy"]
#    - resources: ["podsecuritypolicies"]
#    - verbs: ["use"]
#    - resourceNames: ["prevent-privileged-policy"]
#
# 3. ServiceAccount: psp-sa
#    - Namespace: default
#
# 4. ClusterRoleBinding: prevent-role-binding
#    - Binds ClusterRole prevent-role to ServiceAccount psp-sa in default namespace
#
# Output file: /home/candidate/53/psp-solution.yaml
