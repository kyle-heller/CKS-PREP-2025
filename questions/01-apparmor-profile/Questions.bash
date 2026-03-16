# CKS Practice — AppArmor Profile Enforcement
# Domain: System Hardening (10%)
#
# Enforce a prepared AppArmor profile on a specific worker node and deploy a Pod using it:
#
# 1. Apply the nginx-profile-2 AppArmor profile on the worker node node-01.
# 2. Edit the Pod manifest to reference this profile.
# 3. Deploy the Pod on node-01 and ensure the profile is applied correctly.
