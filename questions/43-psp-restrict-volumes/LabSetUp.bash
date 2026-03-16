#!/bin/bash
set -euo pipefail

# PSP API was removed in K8s 1.25+. KillerCoda runs 1.35.
# This is a MANIFEST-ONLY exercise — write the YAML to a file.

kubectl create namespace restricted --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /home/candidate/43

echo "Lab setup complete."
echo "  Namespace: restricted"
echo "  Output dir: /home/candidate/43/"
echo "  NOTE: PSP API removed in K8s 1.25+. This is a manifest-writing exercise."
echo "  Write PSP + SA + ClusterRole + ClusterRoleBinding to /home/candidate/43/psp-solution.yaml"
