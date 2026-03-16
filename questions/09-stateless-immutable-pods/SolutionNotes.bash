#!/bin/bash
# Solution: Stateless and Immutable Pods
#
# Inspect each pod:
#   kubectl get pod/app -n prod -o yaml | grep -E 'privileged|readOnlyRootFilesystem'
#   kubectl get pods -n prod -o jsonpath="{range .items[*]}{.metadata.name}{': '}{.spec.volumes[*].name}{'\n'}{end}"
#
# Delete non-compliant pods:
#   kubectl delete --grace-period=0 --force pod app -n prod
#   kubectl delete --grace-period=0 --force pod gcc -n prod
#
# frontend should remain (compliant)
#
# Notes:
# - Stateless: Pods should not persist data in hostPath or PVC volumes.
#   emptyDir is considered stateless (ephemeral, dies with the pod).
# - Immutable: Pods should not run as privileged and must have
#   readOnlyRootFilesystem: true.
# - app is non-compliant: privileged=true AND readOnlyRootFilesystem=false
# - gcc is non-compliant: uses hostPath volume (stateful)
# - frontend is compliant: readOnlyRootFilesystem=true, privileged=false, no hostPath
