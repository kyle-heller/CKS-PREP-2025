#!/bin/bash
# Solution: Worker Node Upgrade
#
# Step 1: Identify nodes and versions
#   kubectl get nodes -o wide
#
# Step 2: Drain the worker (from control plane)
#   kubectl drain node01 --ignore-daemonsets
#
# Step 3: SSH to the worker
#   ssh node01
#   sudo -i
#
# Step 4: Update APT repo to target version
#   vim /etc/apt/sources.list.d/kubernetes.list
#   # Change to: deb [signed-by=...] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /
#
# Step 5: Upgrade kubeadm
#   sudo apt-mark unhold kubeadm
#   sudo apt-get update && sudo apt-get install -y kubeadm='1.33.0-*'
#   sudo apt-mark hold kubeadm
#
# Step 6: Apply the node upgrade
#   sudo kubeadm upgrade node
#
# Step 7: Upgrade kubelet and kubectl
#   sudo apt-mark unhold kubelet kubectl
#   sudo apt-get install -y kubelet='1.33.0-*' kubectl='1.33.0-*'
#   sudo apt-mark hold kubelet kubectl
#
# Step 8: Restart kubelet
#   sudo systemctl daemon-reload
#   sudo systemctl restart kubelet
#   exit
#
# Step 9: Uncordon (from control plane)
#   kubectl uncordon node01
#
# Verify:
#   kubectl get nodes
#   # node01 should show Ready and v1.33.0
#
# Notes:
#   - Always drain before upgrading to safely evict pods
#   - --ignore-daemonsets is needed because DaemonSet pods can't be evicted
#   - kubeadm must be upgraded BEFORE running kubeadm upgrade node
#   - The kubelet version must not exceed the API server version
#   - apt-mark hold prevents accidental package upgrades
#   - Order: drain -> kubeadm -> kubeadm upgrade -> kubelet/kubectl -> restart -> uncordon
