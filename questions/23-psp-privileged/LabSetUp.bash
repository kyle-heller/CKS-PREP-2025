#!/bin/bash
set -euo pipefail

# PSP API was removed in K8s 1.25+. KillerCoda runs 1.35.
# This is a MANIFEST-ONLY exercise — write the YAML and commands to a file.

kubectl create namespace staging --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /home/candidate/23

echo "Lab setup complete."
echo "  Namespace: staging"
echo "  Output dir: /home/candidate/23/"
echo "  NOTE: PSP API removed in K8s 1.25+. This is a manifest-writing exercise."
echo "  Write PSP YAML + ClusterRole + binding commands to /home/candidate/23/psp-solution.yaml"
