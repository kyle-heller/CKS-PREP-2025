# CKS Practice — PSP Restrict Volumes (Manifest-Only)
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# NOTE: PodSecurityPolicy API was removed in Kubernetes 1.25+.
# This is a MANIFEST-WRITING exercise. Write all resources to a file.
#
# Context:
#   Namespace: restricted
#   Output file: /home/candidate/43/psp-solution.yaml
#
# Tasks:
#
# 1. Write a PodSecurityPolicy named "prevent-volume-policy" that:
#    - Allows ONLY persistentVolumeClaim volume types (no hostPath, emptyDir, etc.)
#    - Blocks privileged containers (privileged: false)
#    - Prevents privilege escalation (allowPrivilegeEscalation: false)
#    - Requires containers to run as non-root (MustRunAsNonRoot)
#
# 2. Write a ServiceAccount named "psp-sa" in the "restricted" namespace
#
# 3. Write a ClusterRole named "psp-role" that grants the "use" verb
#    on the PodSecurityPolicy "prevent-volume-policy"
#
# 4. Write a ClusterRoleBinding named "psp-role-binding" that binds
#    ClusterRole "psp-role" to ServiceAccount "psp-sa" in "restricted" namespace
#
# Write ALL resources (PSP, SA, ClusterRole, ClusterRoleBinding) as a
# multi-document YAML file to /home/candidate/43/psp-solution.yaml
#
# Verify with:
#   cat /home/candidate/43/psp-solution.yaml
#   grep 'persistentVolumeClaim' /home/candidate/43/psp-solution.yaml
