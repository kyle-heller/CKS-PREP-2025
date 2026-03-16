#!/bin/bash
# trivy image --severity HIGH,CRITICAL --output /opt/trivy-vulnerable.txt ubuntu:18.04
# trivy image --severity HIGH,CRITICAL registry.k8s.io/kube-apiserver:v1.24.0 >> /opt/trivy-vulnerable.txt
# trivy image --severity HIGH,CRITICAL registry.k8s.io/kube-scheduler:v1.23.0 >> /opt/trivy-vulnerable.txt
# trivy image --severity HIGH,CRITICAL postgres:12 >> /opt/trivy-vulnerable.txt
# trivy image --severity HIGH,CRITICAL httpd:2.4.49 >> /opt/trivy-vulnerable.txt
