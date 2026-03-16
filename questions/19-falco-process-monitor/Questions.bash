# CKS Practice — Falco Process Monitoring
# Domain: Monitoring, Logging and Runtime Security (20%)
#
# Monitor containers for process execution using Falco:
#
# 1. Write a Falco rule at /home/candidate/falco-rule.yaml:
#    - Detect new process execution in containers
#    - Use evt.type, evt.is_open_exec, and container in the condition
#    - Output format: timestamp,uid,processName (use %evt.time,%user.uid,%proc.name)
#    - Priority: ERROR
#
# 2. Configure /etc/falco/falco.yaml to write alerts to a file:
#    - file_output.enabled: true
#    - file_output.filename: /opt/falco-alerts/details
#
# 3. Restart Falco: systemctl restart falco.service
