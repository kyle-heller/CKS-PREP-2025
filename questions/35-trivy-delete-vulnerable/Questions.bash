# CKS Practice — Trivy: Scan and Delete Vulnerable Pods
# Domain: Supply Chain Security (20%)
#
# Task:
# 1. In namespace nato, scan all Pod images using trivy for HIGH/CRITICAL vulns
# 2. Delete any Pods running vulnerable images (force delete, grace-period 0)
# 3. Only nginx:1.25 (latest stable) should remain — it has no HIGH/CRITICAL vulns
#
# Context:
# - trivy image --severity HIGH,CRITICAL <image> scans for vulnerabilities
# - Older images accumulate known CVEs over time
# - On the CKS exam, you must identify and remove vulnerable workloads
# - Use --no-progress flag with trivy to keep output clean
