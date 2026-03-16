#!/bin/bash
# Solution: Trivy Image Scanning
#
# Use trivy to scan each image for HIGH and CRITICAL vulnerabilities.
# The first scan uses --output to create the file.
# Subsequent scans use >> to append.
#
# trivy image --severity HIGH,CRITICAL --output /opt/trivy-vulnerable.txt ubuntu:18.04
# trivy image --severity HIGH,CRITICAL registry.k8s.io/kube-apiserver:v1.24.0 >> /opt/trivy-vulnerable.txt
# trivy image --severity HIGH,CRITICAL registry.k8s.io/kube-scheduler:v1.23.0 >> /opt/trivy-vulnerable.txt
# trivy image --severity HIGH,CRITICAL postgres:12 >> /opt/trivy-vulnerable.txt
# trivy image --severity HIGH,CRITICAL httpd:2.4.49 >> /opt/trivy-vulnerable.txt
#
# Key flags:
#   --severity HIGH,CRITICAL  Only show HIGH and CRITICAL CVEs
#   --output <file>           Write to file (first scan)
#   >> <file>                 Append to file (subsequent scans)
#
# Verify:
#   cat /opt/trivy-vulnerable.txt | head -50
#   wc -l /opt/trivy-vulnerable.txt
