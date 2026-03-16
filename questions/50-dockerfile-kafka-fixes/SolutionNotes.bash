#!/bin/bash
# Solution: Dockerfile and Deployment Fixes (Kafka)
#
# Dockerfile fixes:
#   FROM ubuntu:latest  ->  FROM ubuntu:22.04   (pin to specific version)
#   USER root           ->  USER nobody          (non-root user, UID 65535)
#
# Deployment manifest fixes:
#   runAsUser: 0                  ->  runAsUser: 65535              (non-root UID)
#   privileged: true              ->  privileged: false             (drop privileged mode)
#   readOnlyRootFilesystem: false ->  readOnlyRootFilesystem: true  (immutable root fs)
#
# Why each fix matters:
#
# 1. FROM ubuntu:latest — the :latest tag is mutable. Every pull may fetch
#    a different image, breaking reproducibility and potentially introducing
#    vulnerabilities. Pin to a known version like ubuntu:22.04.
#
# 2. USER root — running as root inside a container means any container
#    escape gives the attacker root on the host. Use nobody (UID 65535)
#    which has no login shell and no home directory.
#
# 3. runAsUser: 0 — numeric equivalent of root. Change to 65535 to match
#    the Dockerfile's nobody user.
#
# 4. privileged: true — gives the container nearly all host capabilities
#    and access to host devices. Always set to false unless absolutely required.
#
# 5. readOnlyRootFilesystem: true — prevents the container process from
#    writing to the root filesystem. Attackers cannot plant binaries or
#    modify configs. Use emptyDir volumes for any writable paths needed.
#
# CKS tip: These Dockerfile + Deployment combo questions appear frequently.
# The pattern is always the same: pin versions, drop root, drop privileges.
