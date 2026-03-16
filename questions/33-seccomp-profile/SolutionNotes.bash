#!/bin/bash
# CKS Practice — Seccomp Profile — Solution Notes
# Domain: System Hardening (10%)

# Step 1: Create the custom Seccomp profile
# Path: /var/lib/kubelet/seccomp/profiles/seccomp-profile.json
#
# cat > /var/lib/kubelet/seccomp/profiles/seccomp-profile.json << 'EOF'
# {
#   "defaultAction": "SCMP_ACT_ERRNO",
#   "architectures": ["SCMP_ARCH_X86_64", "SCMP_ARCH_X86", "SCMP_ARCH_X32"],
#   "syscalls": [
#     {
#       "names": ["read", "write", "exit", "sigreturn"],
#       "action": "SCMP_ACT_ALLOW"
#     }
#   ]
# }
# EOF
#
# Key points:
# - defaultAction: SCMP_ACT_ERRNO blocks all syscalls not explicitly allowed
# - Only read, write, exit, sigreturn are permitted
# - SCMP_ACT_ALLOW whitelists specific syscalls
#
# Step 2: Update Deployment to use the profile
#
# kubectl edit deployment webapp -n secure-app
#
# Add to pod spec (or container spec):
#   securityContext:
#     seccompProfile:
#       type: Localhost
#       localhostProfile: profiles/seccomp-profile.json
#
# The localhostProfile path is relative to /var/lib/kubelet/seccomp/
# So "profiles/seccomp-profile.json" resolves to /var/lib/kubelet/seccomp/profiles/seccomp-profile.json
#
# Step 3: Verify
# kubectl get deployment webapp -n secure-app -o yaml | grep -A3 seccomp
