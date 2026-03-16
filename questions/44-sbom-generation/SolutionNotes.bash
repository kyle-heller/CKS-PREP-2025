#!/bin/bash
# Solution: SBOM Generation
#
# SBOM = Software Bill of Materials. Lists all packages/dependencies in a container image.
# Two major formats: SPDX (Linux Foundation) and CycloneDX (OWASP).
#
# Step 1: Generate SPDX-JSON SBOM with bom (Kubernetes SIG tool)
#
#   bom generate -o /opt/candidate/13/sbom1.json --format json \
#     --image registry.k8s.io/kube-apiserver:v1.32.0
#
#   Notes:
#     - "bom" is the Kubernetes SIG Release SBOM tool
#     - --format json produces SPDX JSON (not tag-value)
#     - SPDX format includes: spdxVersion, SPDXID, packages with PURL identifiers
#
# Step 2: Generate CycloneDX SBOM with trivy
#
#   trivy image --format cyclonedx -o /opt/candidate/13/sbom2.json \
#     registry.k8s.io/kube-controller-manager:v1.32.0
#
#   Notes:
#     - trivy can output multiple formats: table, json, sarif, cyclonedx, spdx, spdx-json
#     - CycloneDX format includes: bomFormat, specVersion, components with purl
#     - First run may take a while to download the vulnerability database
#
# Step 3: Scan existing SBOM for vulnerabilities with trivy sbom
#
#   trivy sbom /opt/candidate/13/sbom_check.json \
#     -o /opt/candidate/13/sbom_result.json
#
#   Notes:
#     - "trivy sbom" takes a previously-generated SBOM as input
#     - Matches components/packages against the trivy vulnerability database
#     - The sbom_check.json contains log4j-core 2.14.1 (CVE-2021-44228 Log4Shell)
#     - Output shows matched CVEs with severity ratings
#     - Useful for scanning SBOMs from third-party vendors without needing the image
#
# Key exam concepts:
#   - bom generates SBOMs in SPDX format (Kubernetes ecosystem tool)
#   - trivy can both generate (CycloneDX/SPDX) and scan SBOMs
#   - SPDX and CycloneDX are the two standard SBOM formats
#   - "trivy sbom" scans an existing SBOM file (no container runtime needed)
#   - SBOMs are critical for supply chain security — know what's in your images
