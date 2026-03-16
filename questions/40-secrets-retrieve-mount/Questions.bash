# CKS Practice — Secrets: Retrieve and Mount
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# 1. A secret named dev-token exists in the dev namespace.
#    Retrieve the value of the "token" key, decode it from base64,
#    and save the decoded content to:
#      /home/candidate/ca.crt
#
# 2. Create a new secret named app-config-secret in the app namespace:
#    - Key APP_USER with value: appadmin
#    - Key APP_PASS with value: Sup3rS3cret
#
# 3. Create a Pod named app-pod in the app namespace:
#    - Image: nginx
#    - Mount the app-config-secret as a volume at /etc/app-config (readOnly)
