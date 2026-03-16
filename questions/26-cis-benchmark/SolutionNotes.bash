#!/bin/bash
# Solution: CIS Benchmark Fixes
#
# Step 1: Fix API Server (/etc/kubernetes/manifests/kube-apiserver.yaml)
#   Change: --authorization-mode=RBAC
#   To:     --authorization-mode=Node,RBAC
#
#   Node authorization restricts kubelets to only read objects related
#   to their own node. Without it, any kubelet can read any node's data.
#
# Step 2: Fix Kubelet (/var/lib/kubelet/config.yaml)
#   authentication:
#     anonymous:
#       enabled: false    # was: true
#   authorization:
#     mode: Webhook       # was: AlwaysAllow
#
#   Then restart:
#     sudo systemctl daemon-reload
#     sudo systemctl restart kubelet
#
# Step 3: Fix etcd (/etc/kubernetes/manifests/etcd.yaml)
#   Add:    - --client-cert-auth=true
#   Remove: - --auto-tls=true
#
#   --client-cert-auth requires client certificates for all connections.
#   --auto-tls generates self-signed certs, bypassing the proper PKI chain.
#
# Step 4: Verify
#   kubectl get nodes                    # cluster should be healthy
#   kube-bench run --targets=master,node,etcd  # re-run to confirm fixes
