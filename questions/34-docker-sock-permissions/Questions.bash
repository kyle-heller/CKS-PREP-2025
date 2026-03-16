# CKS Practice — Docker Socket Permissions
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# Task:
# 1. In namespace ci-cd, find the Pod that mounts /var/run/docker.sock
# 2. Restrict the socket permissions:
#    - chown 65535:65535 /var/run/docker.sock
#    - chmod 0600 /var/run/docker.sock
# 3. Update the Pod's securityContext:
#    - runAsUser: 65535
#    - runAsGroup: 65535
#    - readOnlyRootFilesystem: true
#    - allowPrivilegeEscalation: false
#    - capabilities: drop ALL
#
# Context:
# - Mounting the Docker socket gives a container full control over the Docker daemon
# - Restricting socket permissions limits which processes can interact with it
# - Combining socket permissions with Pod securityContext provides defense in depth
# - In a real cluster, consider alternatives like Kaniko or Buildah instead of Docker-in-Docker
