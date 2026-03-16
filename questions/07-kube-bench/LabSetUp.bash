#!/bin/bash
set -euo pipefail

MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"
ETCD_MANIFEST="/etc/kubernetes/manifests/etcd.yaml"
KUBELET_CONFIG="/var/lib/kubelet/config.yaml"

# --- Backup originals ---
cp "$MANIFEST" /tmp/kube-apiserver-q07-backup.yaml
cp "$ETCD_MANIFEST" /tmp/etcd-q07-backup.yaml
cp "$KUBELET_CONFIG" /tmp/kubelet-config-q07-backup.yaml

# --- Misconfigure API Server ---
# Remove --kubelet-certificate-authority if present
sed -i '/--kubelet-certificate-authority/d' "$MANIFEST"
# Add --profiling=true if not present
if ! grep -q '\-\-profiling' "$MANIFEST"; then
  sed -i '/- --authorization-mode/a\    - --profiling=true' "$MANIFEST"
fi

# --- Misconfigure Kubelet ---
# Set anonymous auth to true
sed -i '/anonymous:/,/enabled:/{s/enabled: false/enabled: true/}' "$KUBELET_CONFIG"
# Set authorization mode to AlwaysAllow
sed -i '/authorization:/,/mode:/{s/mode: Webhook/mode: AlwaysAllow/}' "$KUBELET_CONFIG"

# Restart kubelet to pick up insecure config
systemctl daemon-reload
systemctl restart kubelet

# --- Misconfigure ETCD ---
# Add --auto-tls=true and --peer-auto-tls=true
if ! grep -q '\-\-auto-tls' "$ETCD_MANIFEST"; then
  sed -i '/- --trusted-ca-file/a\    - --auto-tls=true' "$ETCD_MANIFEST"
fi
if ! grep -q '\-\-peer-auto-tls' "$ETCD_MANIFEST"; then
  sed -i '/- --auto-tls/a\    - --peer-auto-tls=true' "$ETCD_MANIFEST"
fi

echo "Lab setup complete."
echo "kube-bench has identified security violations in the API server, kubelet, and etcd."
echo "Backups saved (don't peek!)."
echo ""
echo "Hint: Run 'kube-bench run --targets=master,node,etcd' to see findings."
