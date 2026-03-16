# CKS Practice — Seccomp Profile
# Domain: System Hardening (10%)
#
# Task:
# 1. Create a custom Seccomp profile at /var/lib/kubelet/seccomp/profiles/seccomp-profile.json
#    that allows ONLY these syscalls: read, write, exit, sigreturn
#    (default action: SCMP_ACT_ERRNO)
#
# 2. In namespace secure-app, update Deployment webapp to use this Seccomp profile
#    using securityContext.seccompProfile with type: Localhost
#
# Context:
# - Seccomp (Secure Computing) restricts syscalls a container can make
# - Localhost profiles reference files under /var/lib/kubelet/seccomp/
# - The localhostProfile path is relative to the seccomp root directory
