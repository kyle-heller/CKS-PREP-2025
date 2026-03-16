#!/bin/bash
set -euo pipefail

# Create the payments namespace
kubectl create namespace payments --dry-run=client -o yaml | kubectl apply -f -

# Create a sample deployment in the namespace
kubectl create deployment payment-api -n payments --image=nginx --replicas=1 2>/dev/null || true

# Register PeerAuthentication CRD (Istio is not installed on KillerCoda,
# but we need the CRD so kubectl apply/get works for the student)
kubectl apply -f - <<'EOF' 2>/dev/null
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: peerauthentications.security.istio.io
spec:
  group: security.istio.io
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                mtls:
                  type: object
                  properties:
                    mode:
                      type: string
  scope: Namespaced
  names:
    plural: peerauthentications
    singular: peerauthentication
    kind: PeerAuthentication
    shortNames:
      - pa
EOF

echo "Lab setup complete."
echo "Namespace: payments"
echo "Note: Istio is pre-installed on this cluster (simulated)."
echo "      Your task is to configure mTLS for the payments namespace."
