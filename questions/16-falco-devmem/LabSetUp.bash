#!/bin/bash
set -euo pipefail

# Create the malicious deployment — privileged container accessing /dev/mem
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mem-hacker
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mem-hacker
  template:
    metadata:
      labels:
        app: mem-hacker
    spec:
      containers:
      - name: hacker
        image: busybox
        command: ["/bin/sh", "-c"]
        args:
        - |
          while true; do
            cat /dev/mem > /dev/null 2>&1
            sleep 5
          done
        securityContext:
          privileged: true
EOF

# Create skeleton Falco rule file for student to complete
mkdir -p /home/candidate
cat > /home/candidate/falco-rule.yaml << 'RULEEOF'
# Complete this Falco rule to detect containers accessing /dev/mem
#
# Hints:
# - Use evt.is_open_read and evt.is_open_write to match open syscalls
# - Use fd.name to match the file path
# - Include useful output fields: proc.name, proc.cmdline, container.id,
#   container.image.repository, k8s.pod.name, k8s.ns.name

- rule: detect dev mem access
  desc: # ADD DESCRIPTION
  condition: >
    # ADD YOUR CONDITION HERE
  output: # ADD YOUR OUTPUT FORMAT
  priority: WARNING
  tags: [security]
RULEEOF

# Check if Falco is available
if command -v falco &>/dev/null; then
  echo "Falco is installed."
else
  echo "WARNING: Falco is not installed. Run scripts/setup-tools.sh first."
  echo "You can still write the rule and scale the deployment."
fi

echo ""
echo "Lab setup complete."
echo "A malicious Deployment 'mem-hacker' is running in the default namespace."
echo "Skeleton rule file at /home/candidate/falco-rule.yaml"
