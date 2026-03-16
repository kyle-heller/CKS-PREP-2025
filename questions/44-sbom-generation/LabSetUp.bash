#!/bin/bash
set -euo pipefail

# Create output directory
mkdir -p /opt/candidate/13

# Check that bom is installed
if command -v bom &>/dev/null; then
  echo "  bom version: $(bom version 2>&1 | head -1)"
else
  echo "  WARNING: bom not found. Install with: go install sigs.k8s.io/bom/cmd/bom@latest"
fi

# Check that trivy is installed
if command -v trivy &>/dev/null; then
  echo "  trivy version: $(trivy --version 2>&1 | head -1)"
else
  echo "  WARNING: trivy not found. Run scripts/setup-tools.sh first."
fi

# Create a minimal CycloneDX SBOM file for the scan exercise
# Uses a known vulnerable component (log4j-core 2.14.1) so trivy has something to find
cat > /opt/candidate/13/sbom_check.json <<'EOF'
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.4",
  "version": 1,
  "metadata": {
    "timestamp": "2024-01-15T00:00:00Z",
    "component": {
      "type": "application",
      "name": "test-app",
      "version": "1.0.0"
    }
  },
  "components": [
    {
      "type": "library",
      "name": "log4j-core",
      "version": "2.14.1",
      "group": "org.apache.logging.log4j",
      "purl": "pkg:maven/org.apache.logging.log4j/log4j-core@2.14.1"
    },
    {
      "type": "library",
      "name": "spring-core",
      "version": "5.3.18",
      "group": "org.springframework",
      "purl": "pkg:maven/org.springframework/spring-core@5.3.18"
    },
    {
      "type": "library",
      "name": "commons-text",
      "version": "1.9",
      "group": "org.apache.commons",
      "purl": "pkg:maven/org.apache.commons/commons-text@1.9"
    }
  ]
}
EOF

# Remove any existing output files (clean slate for student)
rm -f /opt/candidate/13/sbom1.json
rm -f /opt/candidate/13/sbom2.json
rm -f /opt/candidate/13/sbom_result.json

echo "Lab setup complete."
echo "  Output directory: /opt/candidate/13/"
echo "  Existing SBOM for scanning: /opt/candidate/13/sbom_check.json"
echo "  Task 1: bom generate → sbom1.json (SPDX-JSON, kube-apiserver:v1.32.0)"
echo "  Task 2: trivy image → sbom2.json (CycloneDX, kube-controller-manager:v1.32.0)"
echo "  Task 3: trivy sbom → sbom_result.json (scan sbom_check.json)"
