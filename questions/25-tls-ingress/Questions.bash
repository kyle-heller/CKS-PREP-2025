# CKS Practice — TLS Ingress
# Domain: Cluster Setup (15%)
#
# In namespace testing:
#
# 1. Create a TLS Secret named bingo-tls from the certificate and key:
#    - Cert: /home/candidate/bingo.crt
#    - Key: /home/candidate/bingo.key
#
# 2. Deploy a pod named nginx-pod (image: nginx) and expose it with a Service on port 80
#
# 3. Create an Ingress named bingo-com:
#    - Host: bingo.com
#    - Path: / (Prefix) -> Service nginx-pod port 80
#    - TLS: use secret bingo-tls for host bingo.com
#    - Add annotation to redirect HTTP traffic to HTTPS
