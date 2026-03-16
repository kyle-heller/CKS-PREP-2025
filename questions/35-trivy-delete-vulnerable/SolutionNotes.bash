#!/bin/bash
# CKS Practice — Trivy: Scan and Delete Vulnerable Pods — Solution Notes
# Domain: Supply Chain Security (20%)

# Step 1: List all pods and their images in the nato namespace
# kubectl get pods -n nato -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[0].image}{"\n"}{end}'
#
# Output:
#   nginx-1    nginx:1.25
#   nginx-2    nginx:1.19
#   nginx-3    nginx:1.16

# Step 2: Scan each image with trivy for HIGH and CRITICAL vulnerabilities
# trivy image --severity HIGH,CRITICAL --no-progress nginx:1.25
# trivy image --severity HIGH,CRITICAL --no-progress nginx:1.19
# trivy image --severity HIGH,CRITICAL --no-progress nginx:1.16
#
# Expected results:
#   nginx:1.25 — 0 HIGH/CRITICAL (safe)
#   nginx:1.19 — multiple HIGH/CRITICAL CVEs (vulnerable)
#   nginx:1.16 — multiple HIGH/CRITICAL CVEs (vulnerable)
#
# Tip: Use --quiet flag to only show vulnerabilities, not the full report
# trivy image --severity HIGH,CRITICAL --quiet nginx:1.19

# Step 3: Delete pods running vulnerable images
# kubectl delete pod nginx-2 -n nato --force --grace-period=0
# kubectl delete pod nginx-3 -n nato --force --grace-period=0
#
# The --force --grace-period=0 flags immediately remove the pod without
# waiting for graceful shutdown. This is acceptable in exam scenarios.

# Step 4: Verify only the safe pod remains
# kubectl get pods -n nato
#
# Expected: only nginx-1 (nginx:1.25) remains

# Key concepts:
# - trivy image --severity HIGH,CRITICAL filters for serious vulnerabilities
# - Always scan ALL pod images — don't assume any image is safe
# - On the exam, time is limited: scan, identify, delete, move on
# - In production, you'd update images rather than delete pods
# - trivy can also scan filesystem, config, and IaC (not needed here)
