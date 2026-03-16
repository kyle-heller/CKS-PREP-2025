#!/bin/bash
set -euo pipefail

# Create AppArmor profile on the node
mkdir -p /etc/apparmor.d
cat > /etc/apparmor.d/nginx_apparmor << 'PROFILE'
#include <tunables/global>
profile nginx-profile-2 flags=(attach_disconnected) {
    #include <abstractions/base>
    file,
    # Deny all file writes.
    deny /** w,
}
PROFILE

# Create Pod manifest template (without AppArmor config — student must add it)
mkdir -p /home/candidate
cat > /home/candidate/nginx-pod.yaml << 'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  nodeName: node-01
  containers:
  - name: nginx-pod
    image: nginx:1.19.0
    ports:
    - containerPort: 80
YAML

echo "Lab setup complete. AppArmor profile at /etc/apparmor.d/nginx_apparmor"
echo "Pod manifest at /home/candidate/nginx-pod.yaml"
