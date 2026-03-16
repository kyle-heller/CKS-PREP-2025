# CKS Practice — Docker Socket: SecurityContext Hardening
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# Deployment docker-admin in namespace sandbox mounts /var/run/docker.sock.
# The container currently runs with no security restrictions.
# Reduce the risk by hardening the container's securityContext:
#
# 1. Set runAsUser: 65535
# 2. Set runAsGroup: 65535
# 3. Drop ALL capabilities
# 4. Set readOnlyRootFilesystem: true
# 5. Set allowPrivilegeEscalation: false
#
# The docker.sock volume mount must remain (it is required by the workload).
# The Deployment must still exist in namespace sandbox after your changes.
