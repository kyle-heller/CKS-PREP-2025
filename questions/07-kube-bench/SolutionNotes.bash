#!/bin/bash
# Solution: kube-bench Fixes
#
# Step 1: Run kube-bench to identify violations
#   kube-bench run --targets=master,node,etcd
#
# Step 2: Fix API Server (/etc/kubernetes/manifests/kube-apiserver.yaml)
#   Add:    - --kubelet-certificate-authority=/etc/kubernetes/pki/ca.crt
#   Change: - --profiling=false   (or remove the --profiling=true line)
#
#   The --kubelet-certificate-authority flag tells the API server to verify
#   the kubelet's serving certificate. Without it, the API server connects
#   to kubelets without verifying their identity.
#
#   --profiling=true exposes performance data via /debug/pprof — disable in production.
#
# Step 3: Fix Kubelet (/var/lib/kubelet/config.yaml)
#   authentication:
#     anonymous:
#       enabled: false    # was: true
#     webhook:
#       enabled: true
#     x509:
#       clientCAFile: /etc/kubernetes/pki/ca.crt
#   authorization:
#     mode: Webhook       # was: AlwaysAllow
#
#   Then restart:
#     sudo systemctl daemon-reload
#     sudo systemctl restart kubelet
#
#   Anonymous auth lets unauthenticated requests reach the kubelet API.
#   AlwaysAllow authorization means any request is permitted without RBAC checks.
#
# Step 4: Fix ETCD (/etc/kubernetes/manifests/etcd.yaml)
#   Remove or set to false:
#     - --auto-tls=true     -> remove this line (or set false)
#     - --peer-auto-tls=true -> remove this line (or set false)
#
#   auto-tls generates self-signed certs for client connections — bypasses
#   the proper PKI chain. peer-auto-tls does the same for peer communication.
#
# Step 5: Verify
#   kubectl get nodes                    # cluster should be healthy
#   kubectl get pods -n kube-system      # API server + etcd should restart
#   kube-bench run --targets=master,node,etcd  # re-run to confirm fixes
