#!/bin/bash
set -euo pipefail

# Create an insecure ClusterRoleBinding for anonymous access
kubectl create clusterrolebinding system:anonymous --clusterrole=cluster-admin --user=system:anonymous \
  --dry-run=client -o yaml | kubectl apply -f -

# Modify API server to be insecure (backup first)
MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"
cp "$MANIFEST" /tmp/kube-apiserver-backup.yaml

# Set insecure flags
sed -i 's/--authorization-mode=.*/--authorization-mode=AlwaysAllow/' "$MANIFEST"
sed -i '/--anonymous-auth/d' "$MANIFEST"
sed -i '/--enable-admission-plugins/s/NodeRestriction/AlwaysAdmit/' "$MANIFEST"

echo "Lab setup complete. API server is now insecure. Fix it."
echo "Backup at /tmp/kube-apiserver-backup.yaml (don't peek!)"
