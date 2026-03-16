#!/bin/bash
echo "=== Verify: Worker Node Upgrade Procedure ==="
PASS=true

PROC_FILE="/home/candidate/upgrade-procedure.txt"

if [ ! -f "$PROC_FILE" ]; then
  echo "[FAIL] Procedure file not found at $PROC_FILE"
  exit 1
fi

CONTENT=$(cat "$PROC_FILE")

# Check for drain command
if echo "$CONTENT" | grep -qi 'kubectl drain'; then
  echo "[PASS] Procedure includes 'kubectl drain'"
else
  echo "[FAIL] Missing 'kubectl drain' step"
  PASS=false
fi

# Check for kubeadm upgrade node
if echo "$CONTENT" | grep -qi 'kubeadm upgrade node'; then
  echo "[PASS] Procedure includes 'kubeadm upgrade node'"
else
  echo "[FAIL] Missing 'kubeadm upgrade node' step"
  PASS=false
fi

# Check for kubelet install/upgrade
if echo "$CONTENT" | grep -qiE 'apt.*install.*kubelet|apt-get.*install.*kubelet'; then
  echo "[PASS] Procedure includes kubelet package install"
else
  echo "[FAIL] Missing kubelet package install step (apt-get install kubelet)"
  PASS=false
fi

# Check for kubelet restart
if echo "$CONTENT" | grep -qi 'systemctl.*restart.*kubelet'; then
  echo "[PASS] Procedure includes 'systemctl restart kubelet'"
else
  echo "[FAIL] Missing 'systemctl restart kubelet' step"
  PASS=false
fi

# Check for uncordon
if echo "$CONTENT" | grep -qi 'kubectl uncordon'; then
  echo "[PASS] Procedure includes 'kubectl uncordon'"
else
  echo "[FAIL] Missing 'kubectl uncordon' step"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
