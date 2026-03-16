#!/bin/bash
# Solution: AppArmor Profile Enforcement
#
# Step 1: SSH to the worker node and load the profile
# ssh node-01
# sudo -i
# apparmor_parser -q /etc/apparmor.d/nginx_apparmor
# aa-status | grep -i nginx-profile-2
# exit
#
# Step 2: Edit the Pod manifest to add AppArmor
#
# For Kubernetes >= 1.30 (securityContext):
#   spec:
#     containers:
#     - name: nginx-pod
#       securityContext:
#         appArmorProfile:
#           type: Localhost
#           localhostProfile: nginx-profile-2
#
# For Kubernetes < 1.30 (annotations):
#   metadata:
#     annotations:
#       container.apparmor.security.beta.kubernetes.io/nginx-pod: localhost/nginx-profile-2
#
# Step 3: Apply and verify
# kubectl create -f /home/candidate/nginx-pod.yaml
# kubectl get pods -o wide | grep nginx-pod
# kubectl exec -it nginx-pod -- touch /tmp/test  # should fail
