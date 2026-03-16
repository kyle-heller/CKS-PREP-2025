#!/bin/bash
# Solution: Binary Integrity Verification
#
# Step 1: Navigate to the binaries directory
#   cd /opt/candidate/15/binaries/
#
# Step 2: Verify all checksums at once
#   sha512sum --check ../checksums.txt
#
#   Output will show:
#     kube-apiserver: OK
#     kube-controller-manager: FAILED
#     kube-proxy: OK
#     kubelet: FAILED
#
# Step 3: Delete the binaries that failed verification
#   rm kube-controller-manager
#   rm kubelet
#
# Alternative -- one-liner to check and delete failures:
#   cd /opt/candidate/15/binaries/
#   sha512sum --check ../checksums.txt 2>&1 | grep FAILED | awk -F: '{print $1}' | xargs rm
#
# Key concepts:
# - Always verify downloaded K8s binaries against official checksums
# - sha512sum --check reads checksums from a file and validates each entry
# - Format of checksums file: <hash>  <filename> (two spaces between)
# - In the real exam, you would download checksums from:
#   https://dl.k8s.io/v1.XX.Y/SHA512SUMS
# - Tampered binaries could contain backdoors or malicious code
# - This is a common CKS exam question -- quick points if you know sha512sum --check
