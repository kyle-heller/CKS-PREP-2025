#!/bin/bash
# Solution: Secrets Management
#
# Step 1: Decode the existing secret
#   kubectl get secret admin -n safe -o jsonpath='{.data.username}' | base64 -d > /home/cert-masters/username.txt
#   kubectl get secret admin -n safe -o jsonpath='{.data.password}' | base64 -d > /home/cert-masters/password.txt
#
# Step 2: Create new secret
#   kubectl create secret generic newsecret \
#     --from-literal=username=dbadmin \
#     --from-literal=password=moresecurepas \
#     -n safe
#
# Step 3: Create Pod mounting the secret
#
# apiVersion: v1
# kind: Pod
# metadata:
#   name: mysecret-pod
#   namespace: safe
# spec:
#   containers:
#   - name: db-container
#     image: redis
#     volumeMounts:
#     - name: secret-vol
#       mountPath: /etc/mysecret
#       readOnly: true
#   volumes:
#   - name: secret-vol
#     secret:
#       secretName: newsecret
#
#   kubectl apply -f mysecret-pod.yaml
#
# Verify:
#   kubectl exec mysecret-pod -n safe -- cat /etc/mysecret/username
#   # dbadmin
#   kubectl exec mysecret-pod -n safe -- cat /etc/mysecret/password
#   # moresecurepas
