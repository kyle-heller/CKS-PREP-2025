# CKS Practice — Dockerfile and Deployment Fixes (Couchbase)
# Domain: System Hardening (10%)
#
# You are given a Dockerfile and a Deployment manifest at /home/candidate/10/.
# Both contain security violations that must be fixed.
#
# Fix TWO issues in the Dockerfile:
#   1. The base image uses :latest tag — pin it to a specific version
#   2. The container runs as root — change to user nobody (UID 65535)
#
# Fix TWO issues in the Deployment manifest (deployment.yaml):
#   1. runAsUser is set to 0 (root) — change to 65535 (nobody)
#   2. privileged is set to true — change to false
#
# Rules:
#   - Do not add or remove fields — only edit existing values
#   - Use UID 65535 for the non-root user (nobody)
#   - Files are at /home/candidate/10/
