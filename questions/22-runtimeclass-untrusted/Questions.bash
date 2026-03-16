# CKS Practice — RuntimeClass (untrusted)
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# 1. Create a RuntimeClass named untrusted with handler runsc (gVisor)
# 2. Create a Pod named untrusted:
#    - Image: alpine:3.18
#    - Schedule on the worker node (use nodeName)
#    - Use the untrusted RuntimeClass
#    - Command: sleep 3600
# 3. Capture dmesg output to /opt/course/untrusted-test-dmesg
#
# Note: Pod may be Pending if gVisor is not installed — verify the spec is correct.
