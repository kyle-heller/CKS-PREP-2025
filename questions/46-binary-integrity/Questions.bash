# CKS Practice — Binary Integrity Verification
# Domain: Cluster Hardening (15%)
#
# Kubernetes binary checksums must be verified to detect tampering.
#
# 1. The directory /opt/candidate/15/binaries/ contains 4 Kubernetes binaries:
#    kube-apiserver, kube-controller-manager, kube-proxy, kubelet
# 2. A sha512 checksums file is at /opt/candidate/15/checksums.txt
# 3. Verify each binary against its checksum using sha512sum
# 4. Delete any binaries whose checksums do NOT match
# 5. Only valid (matching) binaries should remain in the directory
