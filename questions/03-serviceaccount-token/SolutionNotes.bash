#!/bin/bash
# Solution: ServiceAccount Token Management
#
# Step 1: Disable automount on default SA
# kubectl patch sa default -n default -p '{"automountServiceAccountToken": false}'
#
# Step 2: Create the Secret
# cat <<EOF | kubectl apply -f -
# apiVersion: v1
# kind: Secret
# metadata:
#   name: default-sa-token
#   annotations:
#     kubernetes.io/service-account.name: "default"
# type: kubernetes.io/service-account-token
# EOF
#
# Step 3: Recreate Pod with manual volume mount
# kubectl delete pod nginx-pod
# cat <<EOF | kubectl apply -f -
# apiVersion: v1
# kind: Pod
# metadata:
#   name: nginx-pod
# spec:
#   serviceAccountName: default
#   automountServiceAccountToken: false
#   containers:
#   - name: nginx
#     image: nginx
#     volumeMounts:
#     - name: token-vol
#       mountPath: /var/run/secrets/kubernetes.io/serviceaccount/
#       readOnly: true
#   volumes:
#   - name: token-vol
#     secret:
#       secretName: default-sa-token
# EOF
#
# Verify: kubectl exec -it nginx-pod -- cat /var/run/secrets/kubernetes.io/serviceaccount/token
