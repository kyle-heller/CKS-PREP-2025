#!/bin/bash
# Solution: Find and Kill Process on Port 389
#
# Step 1: Find the PID listening on port 389
#   ss -tulpn | grep :389
#   # or
#   netstat -tulpn | grep :389
#   # Note the PID (e.g., 1234)
#
# Step 2: List open file descriptors
#   ls -l /proc/<PID>/fd > /candidate/13/files.txt
#
# Step 3: Find the executable binary path
#   readlink -f /proc/<PID>/exe
#   # e.g., /usr/local/bin/fake-ldap
#   # or check: ls -l /proc/<PID>/exe
#
# Step 4: Kill the process
#   kill -9 <PID>
#
# Step 5: Delete the binary
#   rm -f /usr/local/bin/fake-ldap
#
# Step 6: Verify
#   ss -tulpn | grep :389    # should be empty
#   ls /usr/local/bin/fake-ldap  # should not exist
#
# Key concepts:
#   - /proc/<PID>/fd lists all open file descriptors
#   - /proc/<PID>/exe is a symlink to the process's binary
#   - Port 389 is LDAP — an unauthorized LDAP service is a security concern
