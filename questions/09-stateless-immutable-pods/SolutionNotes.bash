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
