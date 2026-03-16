# CKS Practice — Secrets Management
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# In namespace safe, a secret named admin exists with username and password.
#
# 1. Retrieve and decode the secret values:
#    - Save the username to /home/cert-masters/username.txt
#    - Save the password to /home/cert-masters/password.txt
#
# 2. Create a new secret named newsecret in the safe namespace:
#    - username=dbadmin
#    - password=moresecurepas
#
# 3. Create a Pod named mysecret-pod in the safe namespace:
#    - Image: redis
#    - Mount newsecret as a volume at /etc/mysecret (readOnly)
