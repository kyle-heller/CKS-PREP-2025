#!/bin/bash
set -euo pipefail

# Create directory structure
mkdir -p /opt/candidate/15/binaries

# Create 4 fake binary files with known content
echo "kube-apiserver-binary-content-v1.35.0-valid" > /opt/candidate/15/binaries/kube-apiserver
echo "kube-controller-manager-binary-content-v1.35.0-valid" > /opt/candidate/15/binaries/kube-controller-manager
echo "kube-proxy-binary-content-v1.35.0-valid" > /opt/candidate/15/binaries/kube-proxy
echo "kubelet-binary-content-v1.35.0-valid" > /opt/candidate/15/binaries/kubelet

# Compute correct sha512 checksums for the "good" binaries
GOOD_API=$(sha512sum /opt/candidate/15/binaries/kube-apiserver | awk '{print $1}')
GOOD_PROXY=$(sha512sum /opt/candidate/15/binaries/kube-proxy | awk '{print $1}')

# Write checksums file: 2 correct (apiserver, proxy), 2 deliberately wrong (controller-manager, kubelet)
cat > /opt/candidate/15/checksums.txt << EOF
${GOOD_API}  kube-apiserver
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa  kube-controller-manager
${GOOD_PROXY}  kube-proxy
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb  kubelet
EOF

echo ""
echo "Lab setup complete."
echo "  Binaries: /opt/candidate/15/binaries/ (4 files)"
echo "  Checksums: /opt/candidate/15/checksums.txt"
echo "  Task: Verify checksums and delete binaries that don't match"
