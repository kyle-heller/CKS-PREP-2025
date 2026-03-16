#!/bin/bash
# CKS Prep 2025 — Install CKS Tools
# Run this once on your cluster node before starting labs.
# Designed for Ubuntu/Debian-based kubeadm clusters (e.g., KillerCoda).

set -euo pipefail

echo "=== CKS Tools Setup ==="

# Trivy
if ! command -v trivy &>/dev/null; then
  echo "[+] Installing Trivy..."
  curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
  echo "    Trivy $(trivy --version 2>/dev/null | head -1) installed."
else
  echo "[ok] Trivy already installed."
fi

# Falco
if ! command -v falco &>/dev/null; then
  echo "[+] Installing Falco..."
  FALCO_FRONTEND=noninteractive apt-get install -y falco 2>/dev/null || {
    curl -fsSL https://falco.org/repo/falcosecurity-packages.asc | \
      gpg --dearmor -o /usr/share/keyrings/falco-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/falco-archive-keyring.gpg] https://download.falco.org/packages/deb stable main" | \
      tee /etc/apt/sources.list.d/falcosecurity.list
    apt-get update -qq
    FALCO_FRONTEND=noninteractive apt-get install -y falco
  }
  echo "    Falco installed."
else
  echo "[ok] Falco already installed."
fi

# AppArmor utilities
if ! command -v aa-status &>/dev/null; then
  echo "[+] Installing AppArmor utilities..."
  apt-get install -y apparmor-utils
  echo "    AppArmor utils installed."
else
  echo "[ok] AppArmor utils already installed."
fi

# KubeSec (Docker-based, just pull the image)
if command -v docker &>/dev/null; then
  echo "[+] Pulling KubeSec Docker image..."
  docker pull kubesec/kubesec:512c5e0 2>/dev/null || echo "    (skipped — Docker pull failed)"
else
  echo "[skip] Docker not available — KubeSec skipped."
fi

# bom (for SBOM generation)
if ! command -v bom &>/dev/null; then
  echo "[+] Installing bom..."
  GO_VERSION=$(go version 2>/dev/null | grep -oP 'go\d+\.\d+' || echo "")
  if [ -n "$GO_VERSION" ]; then
    go install sigs.k8s.io/bom/cmd/bom@latest 2>/dev/null && \
      cp "$(go env GOPATH)/bin/bom" /usr/local/bin/ || echo "    (skipped — go install failed)"
  else
    echo "    (skipped — Go not available)"
  fi
else
  echo "[ok] bom already installed."
fi

# etcdctl
if ! command -v etcdctl &>/dev/null; then
  echo "[+] Installing etcdctl..."
  apt-get install -y etcd-client 2>/dev/null || echo "    (skipped — package not available)"
else
  echo "[ok] etcdctl already installed."
fi

echo ""
echo "=== Tool setup complete ==="
echo "Installed: trivy, falco, apparmor-utils, etcdctl"
echo "Optional: kubesec (docker), bom (go)"
