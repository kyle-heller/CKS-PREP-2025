#!/bin/bash
# CKS Practice — Docker Socket Permissions — Solution Notes
# Domain: Minimize Microservice Vulnerabilities (20%)

# Step 1: Find the pod that mounts docker.sock
# kubectl get pods -n ci-cd -o json | python3 -c "
# import json,sys
# pods = json.load(sys.stdin)
# for p in pods['items']:
#   for v in p['spec'].get('volumes',[]):
#     hp = v.get('hostPath',{}).get('path','')
#     if 'docker.sock' in hp:
#       print(p['metadata']['name'])
# "
# Result: docker-builder

# Step 2: Exec into the pod and restrict socket permissions
# kubectl exec -n ci-cd docker-builder -- chown 65535:65535 /var/run/docker.sock
# kubectl exec -n ci-cd docker-builder -- chmod 0600 /var/run/docker.sock
#
# Note: This only affects the current pod instance. If the pod restarts,
# the host socket permissions revert. For persistence, use an initContainer.

# Step 3: Export the current pod definition, delete the pod, and recreate with securityContext
# Pods are immutable for securityContext — you must delete and recreate.
#
# kubectl get pod docker-builder -n ci-cd -o yaml > /tmp/docker-builder.yaml
# kubectl delete pod docker-builder -n ci-cd
#
# Edit /tmp/docker-builder.yaml to add securityContext under the container spec:
#
# apiVersion: v1
# kind: Pod
# metadata:
#   name: docker-builder
#   namespace: ci-cd
#   labels:
#     app: docker-builder
# spec:
#   containers:
#   - name: builder
#     image: docker:24-dind
#     command: ["sleep", "3600"]
#     securityContext:
#       runAsUser: 65535
#       runAsGroup: 65535
#       readOnlyRootFilesystem: true
#       allowPrivilegeEscalation: false
#       capabilities:
#         drop:
#         - ALL
#     volumeMounts:
#     - name: dockersock
#       mountPath: /var/run/docker.sock
#   volumes:
#   - name: dockersock
#     hostPath:
#       path: /var/run/docker.sock
#
# kubectl apply -f /tmp/docker-builder.yaml

# Key concepts:
# - runAsUser/runAsGroup 65535 is the "nobody" user — minimal privileges
# - readOnlyRootFilesystem prevents writing to the container filesystem
# - allowPrivilegeEscalation: false prevents gaining more privileges than parent process
# - capabilities drop ALL removes all Linux capabilities (NET_RAW, SYS_ADMIN, etc.)
# - Defense in depth: socket permissions + securityContext together limit blast radius
# - On the real exam: Pods are immutable — delete and recreate to change securityContext
