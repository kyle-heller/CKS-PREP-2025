#!/bin/bash
# Solution: Worker Node Upgrade
#
# First, identify your nodes and versions:
# kubectl get nodes
#
# WORKER=<worker-node-name>   (e.g., node01)
# TARGET=<control-plane-version>
#
# Step 1: Drain the worker
# kubectl drain $WORKER --ignore-daemonsets
#
# Step 2: SSH to worker and upgrade
# ssh $WORKER
# sudo -i
#
# # Update kubeadm
# sudo apt-mark unhold kubeadm
# sudo apt-get update && sudo apt-get install -y kubeadm=<target-version>
# sudo apt-mark hold kubeadm
# sudo kubeadm upgrade node
#
# # Update kubelet and kubectl
# sudo apt-mark unhold kubelet kubectl
# sudo apt-get install -y kubelet=<target-version> kubectl=<target-version>
# sudo apt-mark hold kubelet kubectl
#
# sudo systemctl daemon-reload
# sudo systemctl restart kubelet
# exit
#
# Step 3: Uncordon
# kubectl uncordon $WORKER
# kubectl get nodes
