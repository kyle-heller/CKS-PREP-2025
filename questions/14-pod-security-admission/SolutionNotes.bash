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
#
# Notes:
# - Pod Security Admission replaced PodSecurityPolicy (removed in K8s 1.25)
# - Three profiles: privileged (unrestricted), baseline (sensible defaults),
#   restricted (hardened best practices)
# - Three modes: enforce (reject), audit (log), warn (warning message)
# - The restricted profile requires:
#   - runAsNonRoot: true
#   - allowPrivilegeEscalation: false
#   - capabilities.drop: ["ALL"]
#   - No hostPath volumes
#   - No privileged containers
#   - seccompProfile set (RuntimeDefault or Localhost)
# - Tip: use `kubectl label ns --dry-run=server` to test without applying
