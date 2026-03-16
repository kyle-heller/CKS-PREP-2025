#!/bin/bash
# Solution: Falco Process Monitoring
#
# Step 1: Write the Falco rule at /home/candidate/falco-rule.yaml
#
# - rule: Container Drift Detected
#   desc: New executable created in a container
#   condition: >
#     evt.type in (open,openat,creat) and evt.is_open_exec=true and container
#     and not runc_writing_exec_fifo
#     and not runc_var_lib_docker and not user_known_container_drift_activities
#     and evt.rawres>=0
#   output:
#     %evt.time,%user.uid,%proc.name
#   priority: ERROR
#   tags: [security]
#
# Step 2: Configure file output in /etc/falco/falco.yaml
#   file_output:
#     enabled: true
#     keep_alive: false
#     filename: /opt/falco-alerts/details
#
# Step 3: Restart Falco
#   systemctl restart falco.service
#   # Or run manually:
#   falco -M 30 -r /home/candidate/falco-rule.yaml
#
# Key concepts:
#   - evt.type: system call type (open, openat, creat for file execution)
#   - evt.is_open_exec=true: file opened for execution
#   - container: filter for container events only (not host)
#   - Output format uses Falco field macros: %evt.time, %user.uid, %proc.name
#   - file_output sends alert text to a file instead of stdout/syslog
#   - Priority levels: EMERGENCY, ALERT, CRITICAL, ERROR, WARNING, NOTICE, INFO, DEBUG
