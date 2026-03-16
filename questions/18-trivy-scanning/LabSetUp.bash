#!/bin/bash
set -euo pipefail

# Verify trivy is installed
if ! command -v trivy &>/dev/null; then
  echo "WARNING: trivy not found. Run scripts/setup-tools.sh first."
fi

# Create output directory
mkdir -p /opt

# Remove any existing output file
rm -f /opt/trivy-vulnerable.txt

echo "Lab setup complete."
echo "  Ensure trivy is installed (run scripts/setup-tools.sh)"
echo "  Output file: /opt/trivy-vulnerable.txt"
echo "  Scan 5 images for HIGH/CRITICAL vulnerabilities"
