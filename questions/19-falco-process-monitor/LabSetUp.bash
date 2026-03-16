#!/bin/bash
set -euo pipefail

# Create output directory
mkdir -p /opt/falco-alerts

# Create a deployment that spawns processes (for Falco to detect)
kubectl apply -f - <<'EOF' 2>/dev/null
apiVersion: apps/v1
kind: Deployment
metadata:
  name: process-spawner
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: process-spawner
  template:
    metadata:
      labels:
        app: process-spawner
    spec:
      containers:
      - name: spawner
        image: busybox:1.36
        command: ["/bin/sh", "-c"]
        args:
        - |
          while true; do
            ls /tmp >/dev/null 2>&1
            cat /etc/hostname >/dev/null 2>&1
            sleep 5
          done
EOF

# Create skeleton rule file for student to complete
mkdir -p /home/candidate
cat > /home/candidate/falco-rule.yaml << 'YAML'
# TODO: Write a Falco rule to detect new process execution in containers
# Required fields: rule, desc, condition, output, priority
# Output format: timestamp,uid/username,processName
YAML

echo "Lab setup complete."
echo "  Deployment: process-spawner (generates process events)"
echo "  Skeleton rule: /home/candidate/falco-rule.yaml"
echo "  Output directory: /opt/falco-alerts/"
echo "  NOTE: Falco runtime test skipped on KillerCoda (flaky). Verify config files."
