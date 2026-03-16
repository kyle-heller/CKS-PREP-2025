# CKS Practice — SBOM Generation
# Domain: Supply Chain Security (20%)
#
# Context:
#   Output directory: /opt/candidate/13/
#   Tools: bom (Kubernetes SIG), trivy (Aqua Security)
#   An existing SBOM file is at /opt/candidate/13/sbom_check.json
#
# Tasks:
#
# 1. Generate an SPDX-JSON format SBOM for the image:
#      registry.k8s.io/kube-apiserver:v1.32.0
#    Save the output to: /opt/candidate/13/sbom1.json
#    Use the "bom" tool:
#      bom generate -o /opt/candidate/13/sbom1.json --format json \
#        --image registry.k8s.io/kube-apiserver:v1.32.0
#
# 2. Generate a CycloneDX format SBOM for the image:
#      registry.k8s.io/kube-controller-manager:v1.32.0
#    Save the output to: /opt/candidate/13/sbom2.json
#    Use trivy:
#      trivy image --format cyclonedx -o /opt/candidate/13/sbom2.json \
#        registry.k8s.io/kube-controller-manager:v1.32.0
#
# 3. Scan the existing SBOM at /opt/candidate/13/sbom_check.json for
#    vulnerabilities and save the results to: /opt/candidate/13/sbom_result.json
#    Use trivy sbom:
#      trivy sbom /opt/candidate/13/sbom_check.json -o /opt/candidate/13/sbom_result.json
#
# Verify with:
#   ls -la /opt/candidate/13/sbom1.json /opt/candidate/13/sbom2.json /opt/candidate/13/sbom_result.json
#   head -5 /opt/candidate/13/sbom1.json    # should contain SPDX fields
#   head -5 /opt/candidate/13/sbom2.json    # should contain bomFormat/CycloneDX
