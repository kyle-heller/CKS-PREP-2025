# CKS Practice — AppArmor Profile Enforcement
# Domain: System Hardening (10%)
#
# Enforce a prepared AppArmor profile on the worker node and deploy a Pod using it:
#
# 1. SSH to the worker node and load the AppArmor profile at /etc/apparmor.d/nginx_apparmor
# 2. Edit the Pod manifest at /home/candidate/nginx-pod.yaml to use the nginx-profile-2 profile
# 3. Deploy the Pod and verify the AppArmor profile is enforced (file writes should be denied)
