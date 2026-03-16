# CKS Practice — RuntimeClass with gVisor
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# The cluster uses containerd with runc as the default runtime.
# It has been prepared to support runsc (gVisor).
#
# 1. Create a RuntimeClass named sandboxed using runsc.
# 2. Update all Pods in the server namespace to use this runtime.
