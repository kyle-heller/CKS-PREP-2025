#!/bin/bash
set -euo pipefail

# Detect worker node name
WORKER=$(kubectl get nodes --no-headers | grep -v control-plane | awk '{print $1}' | head -1)
if [ -z "$WORKER" ]; then
  echo "ERROR: No worker node found."
  exit 1
fi
echo "Worker node: $WORKER"

# Create AppArmor profile on the WORKER node (not controlplane)
ssh "$WORKER" 'mkdir -p /etc/apparmor.d && cat > /etc/apparmor.d/nginx_apparmor << '"'"'PROFILE'"'"'
#include <tunables/global>
profile nginx-profile-2 flags=(attach_disconnected) {
    #include <abstractions/base>
    file,
    # Allow nginx to run
    /var/run/nginx.pid w,
    /var/cache/nginx/** w,
    /run/nginx.pid w,
    /tmp/** w,
    # Deny writes to sensitive paths
    deny /etc/** w,
    deny /root/** w,
    deny /home/** w,
}
PROFILE'

# Create Pod manifest template (without AppArmor config — student must add it)
mkdir -p /home/candidate
cat > /home/candidate/nginx-pod.yaml << YAML
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  nodeName: $WORKER
  containers:
  - name: nginx-pod
    image: nginx:1.19.0
    ports:
    - containerPort: 80
YAML

echo ""
echo "Lab setup complete."
echo "  AppArmor profile on $WORKER: /etc/apparmor.d/nginx_apparmor"
echo "  Pod manifest: /home/candidate/nginx-pod.yaml"
