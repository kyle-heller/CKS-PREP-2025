#!/bin/bash
set -euo pipefail

# Create namespace and workloads
kubectl create namespace team-dev --dry-run=client -o yaml | kubectl apply -f -

# Deploy stuff (role=stuff)
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stuff
  namespace: team-dev
spec:
  replicas: 1
  selector:
    matchLabels:
      role: stuff
  template:
    metadata:
      labels:
        role: stuff
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
EOF

# Deploy backend (role=backend) + service
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: team-dev
spec:
  replicas: 1
  selector:
    matchLabels:
      role: backend
  template:
    metadata:
      labels:
        role: backend
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: backend
  namespace: team-dev
spec:
  selector:
    role: backend
  ports:
  - port: 80
    targetPort: 80
EOF

# Register CiliumNetworkPolicy CRD if not present (Cilium may or may not be installed)
if ! kubectl get crd ciliumnetworkpolicies.cilium.io &>/dev/null 2>&1; then
  kubectl apply -f - <<'EOF' 2>/dev/null
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: ciliumnetworkpolicies.cilium.io
spec:
  group: cilium.io
  versions:
    - name: v2
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              x-kubernetes-preserve-unknown-fields: true
  scope: Namespaced
  names:
    plural: ciliumnetworkpolicies
    singular: ciliumnetworkpolicy
    kind: CiliumNetworkPolicy
    shortNames:
      - cnp
EOF
  sleep 2
fi

echo "Lab setup complete."
echo "  Namespace: team-dev"
echo "  Deployments: stuff (role=stuff), backend (role=backend)"
echo "  Service: backend"
echo "  CiliumNetworkPolicy CRD registered"
