# CKS Practice — Find and Kill Process on Port 389
# Domain: System Hardening (10%)
#
# A suspicious process is listening on port 389.
#
# 1. Find the PID of the process using ss or netstat
# 2. List all open file descriptors of the process
#    Save the output to /candidate/13/files.txt
# 3. Find the path of the executable binary (using /proc/<PID>/exe)
# 4. Kill the process
# 5. Delete the executable binary from disk
#
# Verify: ss -tulpn | grep :389 (should be empty)
