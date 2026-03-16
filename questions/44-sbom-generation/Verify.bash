#!/bin/bash
echo "=== Verify: SBOM Generation ==="
PASS=true

# Check 1: sbom1.json exists and is non-empty
if [ -f /opt/candidate/13/sbom1.json ]; then
  echo "[PASS] sbom1.json exists"
else
  echo "[FAIL] sbom1.json not found at /opt/candidate/13/sbom1.json"
  PASS=false
fi

if [ -s /opt/candidate/13/sbom1.json ]; then
  echo "[PASS] sbom1.json is non-empty"
else
  echo "[FAIL] sbom1.json is empty"
  PASS=false
fi

# Check 2: sbom1.json contains SPDX content
if grep -qi 'spdx\|SPDXID\|spdxVersion' /opt/candidate/13/sbom1.json 2>/dev/null; then
  echo "[PASS] sbom1.json contains SPDX content"
else
  echo "[FAIL] sbom1.json does not appear to be SPDX format"
  PASS=false
fi

# Check 3: sbom2.json exists and is non-empty
if [ -f /opt/candidate/13/sbom2.json ]; then
  echo "[PASS] sbom2.json exists"
else
  echo "[FAIL] sbom2.json not found at /opt/candidate/13/sbom2.json"
  PASS=false
fi

if [ -s /opt/candidate/13/sbom2.json ]; then
  echo "[PASS] sbom2.json is non-empty"
else
  echo "[FAIL] sbom2.json is empty"
  PASS=false
fi

# Check 4: sbom2.json contains CycloneDX content
if grep -qi 'cyclonedx\|bomFormat' /opt/candidate/13/sbom2.json 2>/dev/null; then
  echo "[PASS] sbom2.json contains CycloneDX content"
else
  echo "[FAIL] sbom2.json does not appear to be CycloneDX format"
  PASS=false
fi

# Check 5: sbom_result.json exists and is non-empty
if [ -f /opt/candidate/13/sbom_result.json ]; then
  echo "[PASS] sbom_result.json exists"
else
  echo "[FAIL] sbom_result.json not found at /opt/candidate/13/sbom_result.json"
  PASS=false
fi

if [ -s /opt/candidate/13/sbom_result.json ]; then
  echo "[PASS] sbom_result.json is non-empty"
else
  echo "[FAIL] sbom_result.json is empty"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
