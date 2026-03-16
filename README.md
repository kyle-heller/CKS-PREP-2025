# CKS Prep 2025

55 hands-on CKS (Certified Kubernetes Security Specialist) practice questions with automated lab setup.

Based on Udemy practice exams, reorganized into self-contained lab scenarios.

## How to Use

### On KillerCoda / any kubeadm cluster

```bash
git clone https://github.com/kyle-heller/CKS-PREP-2025.git ~/cks-prep
cd ~/cks-prep

# Install CKS tools (Falco, Trivy, etc.)
bash scripts/setup-tools.sh

# Run a specific question
bash scripts/run-question.sh 01-apparmor-profile

# Or manually
bash questions/01-apparmor-profile/LabSetUp.bash
cat questions/01-apparmor-profile/Questions.bash
# ... work on the question ...
cat questions/01-apparmor-profile/SolutionNotes.bash

# Check your answer
bash questions/01-apparmor-profile/Verify.bash
```

## Structure

```
questions/
  01-apparmor-profile/
    LabSetUp.bash        # Sets up the scenario
    Questions.bash       # Task description
    SolutionNotes.bash   # Step-by-step solution
    Verify.bash          # Validates your answer
scripts/
  run-question.sh        # Interactive orchestrator
  setup-tools.sh         # Install Falco, Trivy, AppArmor, etc.
  setup-all-labs.sh      # Run all LabSetUp scripts at once
```

## Questions by Domain

### Cluster Setup (15%)
- CIS Benchmark fixes (API server, kubelet, etcd)
- TLS Ingress with HTTPS redirect
- ImagePolicyWebhook admission plugin

### Cluster Hardening (15%)
- API server re-securing (authorization modes, anonymous auth)
- RBAC: Roles, ClusterRoles, RoleBindings
- ServiceAccount token management (automount, projected volumes)
- User CSR creation and approval
- Worker node upgrades

### System Hardening (10%)
- AppArmor profile enforcement
- Seccomp profiles
- Dockerfile and manifest security fixes
- Process identification and binary removal

### Minimize Microservice Vulnerabilities (20%)
- NetworkPolicy (default deny, restricted ingress/egress)
- CiliumNetworkPolicy (mTLS, ICMP deny)
- Pod Security Admission (restricted profile)
- PodSecurityPolicy (deprecated but tested)
- RuntimeClass with gVisor
- Secrets management and mounting
- Docker socket mitigation
- Stateless/immutable Pod enforcement
- Istio mTLS
- Encryption at rest for Secrets

### Supply Chain Security (20%)
- Trivy image scanning
- KubeSec manifest scoring
- ImagePolicyWebhook configuration
- SBOM generation (bom, Trivy CycloneDX)
- Binary integrity verification (sha512)

### Monitoring, Logging and Runtime Security (20%)
- Audit logging configuration and policies
- Falco rules for process monitoring
- Falco rules for /dev/mem detection

## Prerequisites

- Kubernetes cluster (kubeadm-based recommended)
- kubectl configured
- Root/sudo access for node-level tasks
- Internet access for tool installation
