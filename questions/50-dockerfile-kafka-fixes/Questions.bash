# CKS Practice — Dockerfile and Deployment Fixes (Kafka)
# Domain: System Hardening (10%)
#
# You are given a Dockerfile and a Deployment manifest at /home/manifests/.
# Both contain security violations.
#
# Fix TWO issues in the Dockerfile:
#   1. Pin the base image to a specific version (do not use :latest)
#   2. Run the container as a non-root user (use nobody / UID 65535)
#
# Fix TWO issues in the Deployment manifest:
#   1. Set runAsUser to 65535 (non-root)
#   2. Set privileged to false
#   3. Set readOnlyRootFilesystem to true
#
# Rules:
# - Do not add or remove fields — only edit existing values
# - Files are at /home/manifests/
