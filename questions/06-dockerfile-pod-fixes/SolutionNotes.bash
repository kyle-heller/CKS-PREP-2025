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
