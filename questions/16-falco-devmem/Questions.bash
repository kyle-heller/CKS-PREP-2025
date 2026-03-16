# CKS Practice — Falco: Detect /dev/mem Access
# Domain: Monitoring, Logging and Runtime Security (20%)
#
# A malicious container is attempting to access /dev/mem.
# This represents direct access to physical memory and may lead to
# privilege escalation or kernel bypass.
#
# 1. Use Falco to detect the malicious Pod and its Deployment.
# 2. Scale the Deployment replicas to 0 to stop the workload.
