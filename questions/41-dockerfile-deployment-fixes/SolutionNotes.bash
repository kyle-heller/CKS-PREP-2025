#!/bin/bash
# Solution: Dockerfile and Deployment Fixes (Couchbase)
#
# ---- Dockerfile Fixes (/home/candidate/10/Dockerfile) ----
#
# Fix 1: Pin the base image version (do NOT use :latest)
#   FROM ubuntu:latest  ->  FROM ubuntu:22.04
#
#   Why: :latest is a floating tag — it can change without notice, breaking
#   reproducibility and potentially introducing vulnerabilities. Always pin
#   to a specific version for deterministic builds.
#
# Fix 2: Run as non-root user
#   USER root  ->  USER nobody
#   (or: USER 65535)
#
#   Why: Running as root inside a container means a container escape gives
#   the attacker root on the host. The nobody user (UID 65535) is a standard
#   unprivileged system account.
#
# Fixed Dockerfile:
#   FROM ubuntu:22.04
#   RUN apt-get update && apt-get install -y wget gnupg2
#   RUN wget -qO- https://packages.couchbase.com/releases/couchbase-release/couchbase-release-1.0-amd64.deb | dpkg -i - || true
#   RUN apt-get update && apt-get install -y couchbase-server
#   COPY entrypoint.sh /
#   ENTRYPOINT ["/entrypoint.sh"]
#   USER nobody
#
# ---- Deployment Fixes (/home/candidate/10/deployment.yaml) ----
#
# Fix 3: Change runAsUser from 0 to 65535
#   runAsUser: 0  ->  runAsUser: 65535
#
#   Why: UID 0 is root. The question specifies nobody with UID 65535.
#   This matches the Dockerfile USER change for consistency.
#
# Fix 4: Disable privileged mode
#   privileged: true  ->  privileged: false
#
#   Why: privileged: true gives the container nearly all host capabilities
#   and access to all host devices (/dev/*). This is essentially root on
#   the node and should never be used in production.
#
# Fixed securityContext:
#   securityContext:
#     runAsUser: 65535
#     privileged: false
#     allowPrivilegeEscalation: false
#
# Notes:
#   - The question says "do not add or remove fields — only edit existing values"
#     So you change the values of runAsUser and privileged, nothing else.
#   - allowPrivilegeEscalation: false is already set and correct — leave it.
#   - UID 65535 is the standard "nobody" user on most Linux distributions.
#   - In the CKS exam, Dockerfile + Deployment fix questions are common
#     and typically test these exact four patterns:
#       1. Pin base image (no :latest)
#       2. Non-root USER in Dockerfile
#       3. Non-root runAsUser in Pod/Deployment spec
#       4. privileged: false in securityContext
