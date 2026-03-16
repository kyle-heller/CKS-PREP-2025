# CKS Practice — Falco: Monitor Pod for Anomalous Processes
# Domain: Monitoring, Logging and Runtime Security (20%)
#
# A Pod named tomcat is running in the default namespace.
# Your task is to monitor it for anomalous process activity using Falco.
#
# 1. Create a Falco rule in /etc/falco/falco_rules.local.yaml that detects
#    any process spawned inside the tomcat container.
#    - The rule condition must use evt.type (e.g., execve) and filter by container name
#    - The output format must include: %evt.time, %user.uid, %proc.name
#
# 2. Ensure the output directory /home/anomalous/ exists.
#    When Falco runs, anomalous process entries should be stored in:
#      /home/anomalous/report
#    Each line in the format: [timestamp],[uid],[processName]
#
# Note: You do not need to run Falco — just write the correct rule file.
