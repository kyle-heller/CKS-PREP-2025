# CKS Practice — PSP: Restrict Volumes
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# Create PSP prevent-volume-policy allowing only PVC volumes.
# Create SA psp-sa in restricted, ClusterRole psp-role, bind with psp-role-binding.
# Test with a Pod using a Secret volume (should fail).
