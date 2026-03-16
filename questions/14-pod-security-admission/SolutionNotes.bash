#!/bin/bash
# Solution: Pod Security Admission
#
# Fix the deployment manifest:
#   privileged: true        -> (remove or set false)
#   runAsUser: 0            -> runAsUser: 65535
#   capabilities.add: NET_ADMIN -> capabilities.drop: ["ALL"]
#   hostPath volume         -> emptyDir: {}
#
# Add missing fields:
#   runAsNonRoot: true
#   allowPrivilegeEscalation: false
#   readOnlyRootFilesystem: true
#
# kubectl apply -f /home/masters/insecure-deployment.yaml
