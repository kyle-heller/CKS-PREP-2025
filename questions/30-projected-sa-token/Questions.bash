# CKS Practice — Projected ServiceAccount Token
# Domain: Cluster Hardening (15%)
#
# 1. Disable automount on the default ServiceAccount:
#    automountServiceAccountToken: false
#
# 2. Recreate Pod token-demo with a projected serviceAccountToken volume:
#    - Mount path: /var/run/secrets/tokens (readOnly)
#    - Token path: token.jwt
#    - expirationSeconds: 600
#    - audience: https://kubernetes.default.svc.cluster.local
#
# Verify: kubectl exec token-demo -- cat /var/run/secrets/tokens/token.jwt
