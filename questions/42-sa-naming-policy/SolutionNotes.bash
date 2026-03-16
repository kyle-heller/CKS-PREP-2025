#!/bin/bash
# Solution: SA Naming Policy
#
# Step 1: Create ServiceAccount frontend-sa with automountServiceAccountToken: false
#   kubectl apply -f - <<'EOF'
#   apiVersion: v1
#   kind: ServiceAccount
#   metadata:
#     name: frontend-sa
#     namespace: qa
#   automountServiceAccountToken: false
#   EOF
#
#   Alternatively via imperative + patch:
#     kubectl create sa frontend-sa -n qa
#     kubectl patch sa frontend-sa -n qa -p '{"automountServiceAccountToken": false}'
#
# Step 2: Update Pod frontend to use frontend-sa
#   Pods are immutable for serviceAccountName, so export → edit → recreate:
#
#   kubectl get pod frontend -n qa -o yaml > /tmp/frontend-pod.yaml
#   # Edit /tmp/frontend-pod.yaml:
#   #   Change spec.serviceAccountName to frontend-sa
#   #   Remove status section, resourceVersion, uid, creationTimestamp
#   kubectl delete pod frontend -n qa
#   kubectl apply -f /tmp/frontend-pod.yaml
#
#   Or use a one-liner:
#     kubectl get pod frontend -n qa -o yaml | \
#       sed 's/serviceAccountName: default/serviceAccountName: frontend-sa/' | \
#       kubectl replace --force -f -
#
# Step 3: Clean up unused ServiceAccounts
#   First, list all SAs:
#     kubectl get sa -n qa
#   Delete the ones that are NOT default or frontend-sa:
#     kubectl delete sa old-backend-sa -n qa
#     kubectl delete sa temp-sa -n qa
#
#   Or as a loop (useful if you don't know the names):
#     for sa in $(kubectl get sa -n qa -o jsonpath='{.items[*].metadata.name}'); do
#       if [ "$sa" != "default" ] && [ "$sa" != "frontend-sa" ]; then
#         kubectl delete sa "$sa" -n qa
#       fi
#     done
#
# Step 4: Verify
#   kubectl get sa -n qa
#   # Should show only: default, frontend-sa
#   kubectl get sa frontend-sa -n qa -o jsonpath='{.automountServiceAccountToken}'
#   # false
#   kubectl get pod frontend -n qa -o jsonpath='{.spec.serviceAccountName}'
#   # frontend-sa
