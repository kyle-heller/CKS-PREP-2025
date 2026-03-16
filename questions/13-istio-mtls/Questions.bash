# CKS Practice — Istio mTLS
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# Istio is pre-installed on this cluster. The payments namespace
# needs mTLS enforcement.
#
# 1. Label the payments namespace for automatic Istio sidecar injection.
# 2. Create a PeerAuthentication resource named payments-mtls-strict
#    in the payments namespace that enforces STRICT mTLS for all workloads.
#
# Note: On the real exam, Istio would be fully installed. Here we validate
# the correctness of your namespace label and PeerAuthentication manifest.
