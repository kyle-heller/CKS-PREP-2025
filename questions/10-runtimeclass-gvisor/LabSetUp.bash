#!/bin/bash
set -euo pipefail
kubectl create namespace server --dry-run=client -o yaml | kubectl apply -f -
kubectl create deployment workload1 -n server --image=nginx --replicas=1
kubectl create deployment workload2 -n server --image=nginx --replicas=1
kubectl create deployment workload3 -n server --image=nginx --replicas=1
mkdir -p /home/candidate/10
echo "Lab setup complete. Namespace: server, Deployments: workload1-3"
