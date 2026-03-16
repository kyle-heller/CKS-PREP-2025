#!/bin/bash
set -euo pipefail

# Create output directory
mkdir -p /opt/course

# Clean up any existing resources
kubectl delete runtimeclass untrusted --ignore-not-found &>/dev/null || true
kubectl delete pod untrusted --ignore-not-found --grace-period=0 --force &>/dev/null || true

echo "Lab setup complete."
echo "  Output dir: /opt/course/"
echo "  Create RuntimeClass 'untrusted' with handler 'runsc'"
echo "  Deploy Pod 'untrusted' and capture dmesg output"
echo "  NOTE: gVisor (runsc) is not installed — Pod may be Pending. Verify spec, not status."
