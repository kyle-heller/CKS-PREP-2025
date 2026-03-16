#!/bin/bash
set -euo pipefail
mkdir -p /etc/kubernetes/confcontrol

cat > /etc/kubernetes/confcontrol/admission_configuration.yaml << 'YAML'
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
  - name: ImagePolicyWebhook
    configuration:
      imagePolicy:
        kubeConfigFile: /etc/kubernetes/confcontrol/kubeconfig.yaml
        allowTTL: 50
        denyTTL: 50
        retryBackoff: 500
        defaultAllow: true
YAML

cat > /etc/kubernetes/confcontrol/kubeconfig.yaml << 'YAML'
apiVersion: v1
kind: Config
clusters:
- name: test-server
  cluster:
    server: https://test-server.local:8081/image_policy
contexts:
- name: webhook-context
  context:
    cluster: test-server
    user: apiserver
current-context: webhook-context
YAML

echo "Lab setup complete. Config at /etc/kubernetes/confcontrol/"
echo "NOTE: defaultAllow is set to true — you need to change it to false."
