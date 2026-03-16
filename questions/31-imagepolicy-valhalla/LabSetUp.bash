#!/bin/bash
set -euo pipefail

# Create config directory
mkdir -p /etc/kubernetes/imgconfig

# Create admission_configuration.yaml with defaultAllow: true (the bug to fix)
cat > /etc/kubernetes/imgconfig/admission_configuration.yaml << 'YAML'
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
  - name: ImagePolicyWebhook
    configuration:
      imagePolicy:
        kubeConfigFile: /etc/kubernetes/imgconfig/kubeconfig.yaml
        allowTTL: 50
        denyTTL: 50
        retryBackoff: 500
        defaultAllow: true
YAML

# Create kubeconfig pointing to valhalla.local
cat > /etc/kubernetes/imgconfig/kubeconfig.yaml << 'YAML'
apiVersion: v1
kind: Config
clusters:
- name: valhalla-scan
  cluster:
    server: https://valhalla.local:8081/image_policy
contexts:
- name: webhook-context
  context:
    cluster: valhalla-scan
    user: apiserver
current-context: webhook-context
YAML

# Create test resource
mkdir -p /root/16
cat > /root/16/vulnerable-resource.yaml << 'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: vulnerable-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
YAML

echo "Lab setup complete."
echo "  Config dir: /etc/kubernetes/imgconfig/"
echo "  defaultAllow is set to true (WRONG — needs to be false)"
echo "  Webhook endpoint: https://valhalla.local:8081/image_policy"
echo "  Test resource: /root/16/vulnerable-resource.yaml"
