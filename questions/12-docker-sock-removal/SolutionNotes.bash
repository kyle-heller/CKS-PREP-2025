#!/bin/bash
# Solution: Remove docker.sock Mount
#
# kubectl get pods -n dev-ops -o yaml | grep -A 3 "docker.sock"
# kubectl edit deploy docker-hacker -n dev-ops
#
# Remove from volumeMounts:
#   - mountPath: /var/run/docker.sock
#     name: dockersock
#
# Remove from volumes:
#   - name: dockersock
#     hostPath:
#       path: /var/run/docker.sock
#
# Verify:
# kubectl rollout status deploy/docker-hacker -n dev-ops
# kubectl exec -it <pod> -n dev-ops -- ls -l /var/run/docker.sock
# Should say: No such file or directory
#
# Notes:
# - docker.sock gives full Docker daemon access — a container can
#   create sibling containers, access host filesystem, or escape entirely
# - This is one of the most common container breakout vectors
# - Remove BOTH the volumeMount AND the volume definition
# - After editing the Deployment, old pods are replaced automatically
