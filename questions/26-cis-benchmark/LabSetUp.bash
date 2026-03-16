#!/bin/bash
set -euo pipefail

MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"
ETCD_MANIFEST="/etc/kubernetes/manifests/etcd.yaml"
KUBELET_CONFIG="/var/lib/kubelet/config.yaml"

# --- Backup originals ---
cp "$MANIFEST" /tmp/kube-apiserver-q26-backup.yaml
cp "$ETCD_MANIFEST" /tmp/etcd-q26-backup.yaml
cp "$KUBELET_CONFIG" /tmp/kubelet-config-q26-backup.yaml

# --- Misconfigure API Server ---
# Remove Node from authorization-mode (leave only RBAC)
sed -i 's/--authorization-mode=Node,RBAC/--authorization-mode=RBAC/' "$MANIFEST"

# --- Misconfigure Kubelet ---
# Set anonymous auth to true
sed -i '/anonymous:/,/enabled:/{s/enabled: false/enabled: true/}' "$KUBELET_CONFIG"
# Set authorization mode to AlwaysAllow
sed -i '/authorization:/,/mode:/{s/mode: Webhook/mode: AlwaysAllow/}' "$KUBELET_CONFIG"

# Restart kubelet to pick up insecure config
systemctl daemon-reload
systemctl restart kubelet

# --- Misconfigure ETCD ---
# Add --auto-tls=true
if ! grep -q '\-\-auto-tls=true' "$ETCD_MANIFEST"; then
  sed -i '/- --trusted-ca-file/a\    - --auto-tls=true' "$ETCD_MANIFEST"
fi
# Remove --client-cert-auth if present
sed -i '/--client-cert-auth=true/d' "$ETCD_MANIFEST"

echo "Lab setup complete."
echo "  API server: authorization-mode missing Node"
echo "  Kubelet: anonymous auth enabled, AlwaysAllow authorization"
echo "  etcd: auto-tls enabled, client-cert-auth missing"
echo "  Backups saved (don't peek!)."
