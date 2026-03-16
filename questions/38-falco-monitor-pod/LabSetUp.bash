#!/bin/bash
set -euo pipefail

# Create the tomcat pod for monitoring
kubectl run tomcat --image=tomcat:9 --dry-run=client -o yaml | kubectl apply -f -

# Wait for the pod to be scheduled (don't block on Running — image pull may be slow)
kubectl wait --for=condition=PodScheduled pod/tomcat --timeout=30s 2>/dev/null || true

# Create the output directory for Falco reports
mkdir -p /home/anomalous

# Create the Falco rules directory and a skeleton rules file
mkdir -p /etc/falco
cat > /etc/falco/falco_rules.local.yaml << 'YAML'
# Add your custom Falco rule here to detect anomalous processes
# in the tomcat container.
#
# Hints:
# - Use evt.type = execve to detect new process execution
# - Use container.name to filter by the specific container
# - Output format should include: %evt.time, %user.uid, %proc.name
#
# Example structure:
# - rule: <rule name>
#   desc: <description>
#   condition: <sysdig filter expression>
#   output: <output format string>
#   priority: WARNING
YAML

echo ""
echo "Lab setup complete."
echo "  Pod: tomcat (image tomcat:9) in default namespace"
echo "  Output directory: /home/anomalous/"
echo "  Falco rule skeleton: /etc/falco/falco_rules.local.yaml"
