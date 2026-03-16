#!/bin/bash
set -euo pipefail
kubectl create namespace testing --dry-run=client -o yaml | kubectl apply -f -
kubectl run web -n testing --image=nginx --labels="app=web"
kubectl run client -n testing --image=busybox --command -- sleep 3600
echo "Lab setup complete. Namespace: testing, Pods: web, client"
