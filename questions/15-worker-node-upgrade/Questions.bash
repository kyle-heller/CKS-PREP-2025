# CKS Practice — Worker Node Upgrade
# Domain: Cluster Hardening (15%)
#
# The worker node node01 is running Kubernetes v1.32.0 while the control
# plane is already at v1.33.0.
#
# Since both nodes are actually at the same version in this lab,
# this is a procedure knowledge question.
#
# Document the exact upgrade procedure by writing the commands to:
#   /home/candidate/upgrade-procedure.txt
#
# Your procedure must include:
# 1. Drain the worker node (from the control plane)
# 2. SSH to the worker node
# 3. Upgrade kubeadm to the target version
# 4. Run kubeadm upgrade node
# 5. Upgrade kubelet and kubectl to the target version
# 6. Restart the kubelet service
# 7. Exit and uncordon the worker node
