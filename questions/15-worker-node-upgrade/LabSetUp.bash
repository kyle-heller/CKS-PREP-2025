#!/bin/bash
set -euo pipefail

mkdir -p /home/candidate

# Create empty procedure file for student to fill in
cat > /home/candidate/upgrade-procedure.txt << 'EOF'
# Worker Node Upgrade Procedure
# Write the exact commands to upgrade a worker node.
#
# Assume:
#   - Worker node name: node01
#   - Target version: 1.33.0
#   - Current control plane is already at 1.33.0
#   - APT package manager (Debian/Ubuntu)
#
# Include ALL steps: drain, SSH, kubeadm, kubelet/kubectl, restart, uncordon
# Write the actual commands you would run (not pseudocode).

EOF

echo "Lab setup complete."
echo "Write the upgrade procedure to /home/candidate/upgrade-procedure.txt"
echo "Include the exact commands for each step."
