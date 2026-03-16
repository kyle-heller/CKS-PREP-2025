#!/bin/bash
# Solution: Worker Node Upgrade
#
# kubectl drain worker-1 --ignore-daemonsets
# ssh worker-1
# sudo -i
#
# # Update apt repo
# vim /etc/apt/sources.list.d/kubernetes.list
# # Change to v1.33
#
# sudo apt-mark unhold kubeadm
# sudo apt-get update && sudo apt-get install -y kubeadm='1.33.0-0.0'
# sudo apt-mark hold kubeadm
# sudo kubeadm upgrade node
#
# sudo apt-mark unhold kubelet kubectl
# sudo apt-get install -y kubelet='1.33.0-0.0' kubectl='1.33.0-0.0'
# sudo apt-mark hold kubelet kubectl
#
# sudo systemctl daemon-reload
# sudo systemctl restart kubelet
# exit
#
# kubectl uncordon worker-1
# kubectl get nodes
