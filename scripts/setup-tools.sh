#!/bin/bash
# CKS Prep 2025 — Install CKS Tools
# Run this once on your cluster node before starting labs.
# Designed for KillerCoda CKS environment (Ubuntu 24.04, K8s v1.35, Cilium CNI).
#
# Already present on KillerCoda: kubectl, kubeadm, kubelet, etcdctl, helm,
#   docker, containerd, crictl, apparmor, openssl, strace

set -euo pipefail

echo "=== CKS Tools Setup ==="
echo ""

# Trivy — image/filesystem vulnerability scanning
if ! command -v trivy &>/dev/null; then
  echo "[+] Installing Trivy..."
  curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
  echo "    Trivy $(trivy --version 2>/dev/null | head -1) installed."
else
  echo "[ok] Trivy already installed."
fi

# Falco — runtime threat detection
if ! command -v falco &>/dev/null; then
  echo "[+] Installing Falco..."
  # KillerCoda has falco systemd unit but no binary — install via repo
  curl -fsSL https://falco.org/repo/falcosecurity-packages.asc | \
    gpg --dearmor -o /usr/share/keyrings/falco-archive-keyring.gpg 2>/dev/null
  echo "deb [signed-by=/usr/share/keyrings/falco-archive-keyring.gpg] https://download.falco.org/packages/deb stable main" | \
    tee /etc/apt/sources.list.d/falcosecurity.list >/dev/null
  apt-get update -qq
  FALCO_FRONTEND=noninteractive apt-get install -y falco
  echo "    Falco installed."
else
  echo "[ok] Falco already installed."
fi

# KubeSec — Kubernetes manifest security scoring (Docker-based)
if command -v docker &>/dev/null; then
  echo "[+] Pulling KubeSec Docker image..."
  docker pull kubesec/kubesec:512c5e0 2>/dev/null || echo "    (skipped — Docker pull failed)"
else
  echo "[skip] Docker not available — KubeSec skipped."
fi

# kube-bench — CIS Kubernetes Benchmark checks
if ! command -v kube-bench &>/dev/null; then
  echo "[+] Installing kube-bench..."
  KBENCH_VER=$(curl -sL https://api.github.com/repos/aquasecurity/kube-bench/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | tr -d 'v')
  if [ -n "$KBENCH_VER" ]; then
    curl -sLO "https://github.com/aquasecurity/kube-bench/releases/download/v${KBENCH_VER}/kube-bench_${KBENCH_VER}_linux_amd64.deb"
    dpkg -i "kube-bench_${KBENCH_VER}_linux_amd64.deb" 2>/dev/null || apt-get install -f -y
    rm -f "kube-bench_${KBENCH_VER}_linux_amd64.deb"
    echo "    kube-bench ${KBENCH_VER} installed."
  else
    echo "    (skipped — could not determine latest version)"
  fi
else
  echo "[ok] kube-bench already installed."
fi

# gVisor (runsc) — sandboxed container runtime for RuntimeClass questions
if ! command -v runsc &>/dev/null; then
  echo "[+] Installing gVisor (runsc)..."
  curl -fsSL https://gvisor.dev/archive.key | gpg --dearmor -o /usr/share/keyrings/gvisor-archive-keyring.gpg 2>/dev/null
  echo "deb [signed-by=/usr/share/keyrings/gvisor-archive-keyring.gpg arch=$(dpkg --print-architecture)] https://storage.googleapis.com/gvisor/releases release main" | \
    tee /etc/apt/sources.list.d/gvisor.list >/dev/null
  apt-get update -qq
  apt-get install -y runsc
  echo "    gVisor $(runsc --version 2>/dev/null | head -1) installed."
else
  echo "[ok] gVisor (runsc) already installed."
fi

# Seccomp profiles directory
if [ ! -d /var/lib/kubelet/seccomp ]; then
  echo "[+] Creating /var/lib/kubelet/seccomp/ ..."
  mkdir -p /var/lib/kubelet/seccomp/profiles
  echo "    Seccomp directory created."
else
  echo "[ok] Seccomp profiles directory exists."
fi

# Skip tools already present on KillerCoda
echo ""
echo "[ok] Already present: etcdctl, apparmor (aa-status, apparmor_parser), helm, openssl, strace, docker, crictl"

echo ""
echo "=== Tool setup complete ==="
echo "Installed: trivy, falco, kubesec (docker), kube-bench, gvisor/runsc"
echo "Pre-existing: etcdctl, apparmor, helm, openssl, strace, docker, crictl"
echo ""
echo "Note: KillerCoda uses Cilium CNI. CiliumNetworkPolicy and standard"
echo "NetworkPolicy both work. Only NodeRestriction admission plugin is"
echo "enabled — labs will add others (ImagePolicyWebhook, PodSecurity, etc.)"
