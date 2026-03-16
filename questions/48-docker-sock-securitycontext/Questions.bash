# CKS Practice — Docker Socket: SecurityContext
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# Deployment docker-admin in sandbox mounts docker.sock.
# Reduce risk: don't run as root, drop capabilities, read-only filesystem.
