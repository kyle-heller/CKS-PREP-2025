#!/bin/bash
# Solution: Docker Socket SecurityContext Hardening
#
# Step 1: Edit the Deployment
#   kubectl edit deployment docker-admin -n sandbox
#
# Step 2: Add securityContext to the container spec:
#
#   spec:
#     template:
#       spec:
#         containers:
#         - name: docker-admin
#           image: docker:24-cli
#           command: ["sleep", "3600"]
#           securityContext:
#             runAsUser: 65535
#             runAsGroup: 65535
#             readOnlyRootFilesystem: true
#             allowPrivilegeEscalation: false
#             capabilities:
#               drop:
#               - ALL
#           volumeMounts:
#           - name: dockersock
#             mountPath: /var/run/docker.sock
#
# Step 3: Save and verify the rollout
#   kubectl rollout status deployment docker-admin -n sandbox
#
# Alternative -- patch command:
#   kubectl patch deployment docker-admin -n sandbox --type=json -p='[
#     {"op":"add","path":"/spec/template/spec/containers/0/securityContext",
#      "value":{"runAsUser":65535,"runAsGroup":65535,
#               "readOnlyRootFilesystem":true,
#               "allowPrivilegeEscalation":false,
#               "capabilities":{"drop":["ALL"]}}}
#   ]'
#
# Key concepts:
# - Mounting docker.sock gives full Docker daemon access -- extremely dangerous
# - If you cannot remove the mount, at least harden the container:
#   - runAsUser/runAsGroup: non-root UID (65535 = nobody)
#   - Drop ALL capabilities: removes NET_RAW, SYS_ADMIN, etc.
#   - readOnlyRootFilesystem: prevents writing malicious binaries
#   - allowPrivilegeEscalation: false: prevents gaining more privileges
# - In production, prefer alternatives to docker.sock (kaniko, buildah, etc.)
# - The Pod may not start if docker.sock is not available on the node --
#   that is fine for CKS exam purposes; the spec is what matters
