# CKS Practice — ServiceAccount Role for Deployments
# Domain: Cluster Hardening (15%)
#
# In namespace test-system:
#
# 1. Find the ServiceAccount used by the Pod named nginx-pod
#    Save the SA name to /candidate/sa-name.txt
#
# 2. Create a Role named dev-test-role that allows:
#    - Verbs: list, get, watch
#    - Resource: deployments
#    (in namespace test-system)
#
# 3. Create a RoleBinding named dev-test-role-binding that binds
#    dev-test-role to the ServiceAccount you found in step 1
#    (in namespace test-system)
