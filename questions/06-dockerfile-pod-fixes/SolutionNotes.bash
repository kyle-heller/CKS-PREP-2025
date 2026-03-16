#!/bin/bash
# Solution: Dockerfile and Pod Security Fixes
#
# Dockerfile fixes:
#   FROM ubuntu:latest  ->  FROM ubuntu:20.04   (pin version)
#   USER ROOT           ->  USER test-user      (non-root user)
#
# Pod manifest fixes:
#   runAsUser: 0        ->  runAsUser: 5375     (non-root UID)
#   privileged: true    ->  privileged: false   (disable privileged)
#
# Notes:
# - FROM ubuntu:latest pulls whatever is current — no reproducibility guarantee
#   Always pin to a specific version (ubuntu:20.04, nginx:1.23, etc.)
# - USER ROOT runs the container process as root — any container escape
#   gives the attacker root on the host
# - runAsUser: 0 is the numeric equivalent of running as root
# - privileged: true gives the container almost all host capabilities
#   and access to all host devices — essentially root on the host
# - Rule of thumb: "Do not add or remove fields — only edit existing ones"
#   means you change values, not add new securityContext fields
