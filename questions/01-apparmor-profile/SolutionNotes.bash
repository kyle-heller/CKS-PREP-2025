#!/bin/bash
# Solution: AppArmor Profile Enforcement
#
# Step 1: SSH to the worker node and load the profile
# ssh <worker-node>    (e.g., node01)
# apparmor_parser -q /etc/apparmor.d/nginx_apparmor
# aa-status | grep nginx-profile-2
# exit
#
# Step 2: Edit the Pod manifest to add AppArmor
# vi /home/candidate/nginx-pod.yaml
#
# Since this cluster runs K8s v1.35 (>= 1.30), use securityContext:
#
#   spec:
#     containers:
#     - name: nginx-pod
#       image: nginx:1.19.0
#       ports:
#       - containerPort: 80
#       securityContext:
#         appArmorProfile:
#           type: Localhost
#           localhostProfile: nginx-profile-2
#
# Step 3: Apply and verify
# kubectl apply -f /home/candidate/nginx-pod.yaml
# kubectl get pods nginx-pod
# kubectl exec nginx-pod -- touch /etc/test
#   → should fail with "Permission denied" (write to /etc/ denied by AppArmor)
