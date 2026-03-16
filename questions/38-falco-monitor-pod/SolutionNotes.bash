#!/bin/bash
# Solution: Falco — Monitor Pod for Anomalous Processes
#
# Step 1: Write the Falco rule at /etc/falco/falco_rules.local.yaml
#
#   - rule: detect anomalous process in tomcat
#     desc: Detect any process spawned inside the tomcat container
#     condition: >
#       evt.type = execve and container and container.name = tomcat
#     output: >
#       %evt.time,%user.uid,%proc.name
#     priority: WARNING
#     tags: [container, process, cks]
#
#   Alternatively, using the spawned_process macro:
#
#   - rule: detect anomalous process in tomcat
#     desc: Detect any new process execution inside the tomcat container
#     condition: >
#       spawned_process and container.name = tomcat
#     output: >
#       Anomalous process in tomcat: %evt.time,%user.uid,%proc.name
#     priority: WARNING
#     tags: [container, process, cks]
#
# Step 2: Ensure output directory exists
#   mkdir -p /home/anomalous
#
# Step 3: To test (if Falco is installed), redirect output to the report file:
#   falco -r /etc/falco/falco_rules.local.yaml | tee /home/anomalous/report &
#   kubectl exec tomcat -- ls /   # trigger a process inside the container
#   # Check the report file for entries
#
# Step 4: Restart Falco to load the new rule (if running as a service):
#   systemctl restart falco
#   # or: systemctl daemon-reload && systemctl restart falco
#
# Notes:
#   - evt.type = execve matches the execve syscall (new process execution)
#   - "spawned_process" is a Falco macro equivalent to:
#       evt.type in (execve, execveat) and evt.dir=<
#   - "container" is a Falco macro that filters for events inside containers
#     (equivalent to: container.id != host)
#   - container.name = tomcat matches the container name, not the pod name
#   - The output format uses Sysdig field syntax:
#       %evt.time   = event timestamp
#       %user.uid   = user ID of the process
#       %proc.name  = process name (e.g., ls, bash, cat)
#   - The report file format requested is: [timestamp],[uid],[processName]
#     so the output line should produce CSV-like output matching that format
#   - falco_rules.local.yaml is the standard override file — rules here take
#     precedence over /etc/falco/falco_rules.yaml
