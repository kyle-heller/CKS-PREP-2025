# CKS Practice — Worker Node Upgrade
# Domain: Cluster Hardening (15%)
#
# The worker node is running an older Kubernetes version than the control plane.
#
# 1. Drain the worker node
# 2. Upgrade kubeadm, kubelet, and kubectl on the worker to match the control plane version
# 3. Uncordon the worker node and verify it shows the updated version
