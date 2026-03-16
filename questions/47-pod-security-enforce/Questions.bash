# CKS Practice — Pod Security: Enforce Restricted
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# A Deployment in namespace team-blue runs a privileged container.
# Pod Security Admission must be used to enforce the restricted profile.
#
# 1. Label namespace team-blue with pod-security.kubernetes.io/enforce=restricted
# 2. Delete one of the Pods from the privileged-runner Deployment
#    (the ReplicaSet will try to recreate it and fail due to the new policy)
# 3. Capture the ReplicaSet's FailedCreate events to /opt/candidate/16/logs
#    (use kubectl describe or kubectl get events)
