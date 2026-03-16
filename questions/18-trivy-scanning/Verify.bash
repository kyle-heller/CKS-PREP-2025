#!/bin/bash
echo "=== Verify: Trivy Scanning ==="
PASS=true

# Check 1: Output file exists
if [ -f /opt/trivy-vulnerable.txt ]; then
  echo "[PASS] Output file /opt/trivy-vulnerable.txt exists"
else
  echo "[FAIL] Output file /opt/trivy-vulnerable.txt not found"
  PASS=false
fi

# Check 2: File is not empty
if [ -s /opt/trivy-vulnerable.txt ]; then
  echo "[PASS] File is not empty"
else
  echo "[FAIL] File is empty"
  PASS=false
fi

# Check 3: Contains output for all 5 images
IMAGES=("ubuntu" "kube-apiserver" "kube-scheduler" "postgres" "httpd")
for img in "${IMAGES[@]}"; do
  if grep -qi "$img" /opt/trivy-vulnerable.txt 2>/dev/null; then
    echo "[PASS] Output contains scan for $img"
  else
    echo "[FAIL] Output missing scan for $img"
    PASS=false
  fi
done

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
