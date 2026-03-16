# CKS Practice — KubeSec Scanning
# Domain: Supply Chain Security (20%)
#
# A pod manifest exists at /home/candidate/kubesec-test.yaml with no security context.
#
# 1. Scan the manifest using KubeSec (Docker image or binary)
# 2. Apply security hardening to achieve a score of at least 4:
#    - Set runAsUser to a non-root UID
#    - Set runAsNonRoot: true
#    - Set allowPrivilegeEscalation: false
#    - Set readOnlyRootFilesystem: true
#    - Drop ALL capabilities
# 3. Re-scan to confirm score >= 4
