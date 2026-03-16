# CKS Practice — Falco: Detect /dev/mem Access
# Domain: Monitoring, Logging and Runtime Security (20%)
#
# A malicious container is attempting to access /dev/mem directly.
# This represents access to physical memory and could lead to
# privilege escalation or kernel bypass.
#
# 1. Complete the Falco rule at /home/candidate/falco-rule.yaml to detect
#    any container reading or writing to /dev/mem.
#    Include output fields: proc.name, proc.cmdline, container.id,
#    container.image.repository, k8s.pod.name, k8s.ns.name
#
# 2. Identify the Deployment responsible and scale it to 0 replicas.
#
# If Falco is installed, test your rule with:
#   falco -r /home/candidate/falco-rule.yaml
