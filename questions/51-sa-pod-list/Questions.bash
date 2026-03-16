# CKS Practice — ServiceAccount with Pod List Permissions
# Domain: Cluster Hardening (15%)
#
# Create the following resources in the default namespace:
#
# 1. ServiceAccount: backend-sa
#
# 2. Role: pod-reader
#    - Verbs: list, get
#    - Resource: pods
#    - API group: "" (core)
#
# 3. RoleBinding: pod-reader-binding
#    - Binds Role pod-reader to ServiceAccount backend-sa
#
# 4. Pod: backend-pod
#    - Image: bitnami/kubectl:latest
#    - ServiceAccount: backend-sa
#    - Command: sleep 3600
#
# All resources in the default namespace.
