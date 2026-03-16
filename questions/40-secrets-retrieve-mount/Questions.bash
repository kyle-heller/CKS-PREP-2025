# CKS Practice — Secrets: Retrieve and Mount
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# Retrieve CA cert from existing secret in dev namespace, save to ca.crt.
# Create secret app-config-secret (APP_USER=appadmin, APP_PASS=Sup3rS3cret).
# Deploy Pod app-pod mounting the secret at /etc/app-config.
