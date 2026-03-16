# CKS Practice — PodSecurityPolicy (Manifest Exercise)
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# NOTE: PSP API was removed in K8s 1.25+. This is a MANIFEST-WRITING exercise.
# Write all resources and commands to /home/candidate/23/psp-solution.yaml
#
# 1. Write a PodSecurityPolicy named prevent-psp-policy:
#    - Block privileged containers (privileged: false)
#    - Prevent privilege escalation
#    - Drop ALL capabilities
#    - Restrict volume types to safe defaults
#    - Require non-root user
#    - Read-only root filesystem
#
# 2. Include commands to:
#    - Create ClusterRole restrict-access-role (verb: use on the PSP)
#    - Create ServiceAccount psp-restrict-sa in staging namespace
#    - Create ClusterRoleBinding restrict-access-bind
