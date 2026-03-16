#!/bin/bash
set -euo pipefail
kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f -

# Compliant pod
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  namespace: prod
spec:
  containers:
  - name: nginx
    image: nginx
    securityContext:
      readOnlyRootFilesystem: true
      privileged: false
EOF

# Non-immutable pod (privileged)
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: app
  namespace: prod
spec:
  containers:
  - name: app
    image: nginx
    securityContext:
      privileged: true
      readOnlyRootFilesystem: false
EOF

# Stateful pod (hostPath)
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: gcc
  namespace: prod
spec:
  containers:
  - name: gcc
    image: nginx
    volumeMounts:
    - mountPath: /data
      name: host-vol
  volumes:
  - name: host-vol
    hostPath:
      path: /tmp/data
EOF

echo "Lab setup complete. Namespace: prod, Pods: frontend, app, gcc"
