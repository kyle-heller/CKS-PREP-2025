#!/bin/bash
set -euo pipefail

# Verify trivy is installed
if ! command -v trivy &>/dev/null; then
  echo "WARNING: trivy not found. Run scripts/setup-tools.sh first."
fi

# Create namespace
kubectl create namespace nato --dry-run=client -o yaml | kubectl apply -f -

# Deploy 3 pods with different nginx versions
# nginx:1.25 — latest stable, no HIGH/CRITICAL vulns (should survive)
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: nginx-1
  namespace: nato
  labels:
    app: nginx
    version: "1.25"
spec:
  containers:
  - name: nginx
    image: nginx:1.25
    ports:
    - containerPort: 80
EOF

# nginx:1.19 — old version with known vulnerabilities (should be deleted)
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: nginx-2
  namespace: nato
  labels:
    app: nginx
    version: "1.19"
spec:
  containers:
  - name: nginx
    image: nginx:1.19
    ports:
    - containerPort: 80
EOF

# nginx:1.16 — very old version with known vulnerabilities (should be deleted)
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: nginx-3
  namespace: nato
  labels:
    app: nginx
    version: "1.16"
spec:
  containers:
  - name: nginx
    image: nginx:1.16
    ports:
    - containerPort: 80
EOF

echo "Lab setup complete."
echo "  Namespace: nato"
echo "  Pods: nginx-1 (nginx:1.25), nginx-2 (nginx:1.19), nginx-3 (nginx:1.16)"
echo "  Task: Scan images with trivy, delete pods with HIGH/CRITICAL vulns"
