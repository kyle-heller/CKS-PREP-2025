# CKS Practice — Remove docker.sock Mount
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# A Pod in namespace dev-ops is mounting /var/run/docker.sock from the host.
# This gives the container privileged access to the Docker daemon.
#
# 1. Identify the Pod(s) mounting docker.sock.
# 2. Update their Deployment(s) to remove the volume mount.
# 3. Verify containers can no longer access /var/run/docker.sock.
