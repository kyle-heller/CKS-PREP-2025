#!/bin/bash
set -euo pipefail

# Create namespaces
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace app --dry-run=client -o yaml | kubectl apply -f -

# Create the existing secret in dev namespace that the student must decode
# The token value simulates a CA certificate (base64-encoded by K8s automatically)
kubectl create secret generic dev-token -n dev \
  --from-literal=token="LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0KTUlJQmR6Q0NBUnlnQXdJQkFnSUJBREFLQmdncWhrak9QUVFEQWpBak1TRXdId1lEVlFRRERCaHIKTTNNdGMyVnlkbVZ5TFdOaFFEZzBNVEl3TVRZM01UQWVGdzB5TmpBeE1ERXdNREF3TURCYUZ3MHoKTmpBeE1ERXdNREF3TURCY01DTXhJVEFmQmdOVkJBTU1HR3N6Y3kxelpYSjJaWEl0WTJGQQo9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K" \
  --dry-run=client -o yaml | kubectl apply -f -

# Create output directory
mkdir -p /home/candidate

echo ""
echo "Lab setup complete."
echo "  Namespaces: dev, app"
echo "  Secret: dev-token in dev namespace (contains 'token' key)"
echo "  Output file: /home/candidate/ca.crt"
