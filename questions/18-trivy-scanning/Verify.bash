#!/bin/bash
echo "=== Verify: Trivy Scanning ==="
[ -f /opt/trivy-vulnerable.txt ] && echo "[PASS] Output file exists" || echo "[FAIL] File not found"
[ -s /opt/trivy-vulnerable.txt ] && echo "[PASS] File is not empty" || echo "[FAIL] File is empty"
