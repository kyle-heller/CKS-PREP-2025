#!/bin/bash
# Solution: kube-bench Fixes
#
# Run: kube-bench run --targets=master,node,etcd
#
# API Server (/etc/kubernetes/manifests/kube-apiserver.yaml):
#   - --feature-gates=RotateKubeletServerCertificate=true
#   - --enable-admission-plugins=...,PodSecurityPolicy
#   - --kubelet-certificate-authority=/etc/kubernetes/pki/ca.crt
#
# Kubelet (/var/lib/kubelet/config.yaml):
#   authentication:
#     anonymous:
#       enabled: false
#     webhook:
#       enabled: true
#   authorization:
#     mode: Webhook
#   sudo systemctl daemon-reexec && sudo systemctl restart kubelet
#
# ETCD (/etc/kubernetes/manifests/etcd.yaml):
#   - --auto-tls=false
#   - --peer-auto-tls=false
#
# Verify: kube-bench run --targets=master,node,etcd
