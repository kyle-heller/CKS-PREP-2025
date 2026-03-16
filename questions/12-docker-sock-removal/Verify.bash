#!/bin/bash
echo "=== Verify: docker.sock Removal ==="
PASS=true

# Check actual spec (not annotations which may retain old config)
VOL_PATHS=$(kubectl get deploy docker-hacker -n dev-ops \
  -o jsonpath='{range .spec.template.spec.volumes[*]}{.hostPath.path}{"\n"}{end}' 2>/dev/null || true)
MOUNT_PATHS=$(kubectl get deploy docker-hacker -n dev-ops \
  -o jsonpath='{range .spec.template.spec.containers[0].volumeMounts[*]}{.mountPath}{"\n"}{end}' 2>/dev/null || true)
if echo "$VOL_PATHS$MOUNT_PATHS" | grep -q "docker.sock"; then
  echo "[FAIL] docker.sock still mounted in deployment"
  PASS=false
else
  echo "[PASS] docker.sock mount removed from deployment"
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
