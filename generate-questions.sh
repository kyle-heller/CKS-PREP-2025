#!/bin/bash
# Generates all question files for CKS-PREP-2025
set -euo pipefail
cd "$(dirname "$0")"
Q="questions"

###############################################################################
# HELPER
###############################################################################
mkq() {
  local dir="$Q/$1"
  mkdir -p "$dir"
  cat > "$dir/Questions.bash"
  # LabSetUp, SolutionNotes, Verify written separately below
}

###############################################################################
# TEST 1
###############################################################################

#── Q01 ──────────────────────────────────────────────────────────────────────
cat > "$Q/01-apparmor-profile/Questions.bash" << 'QEOF'
# CKS Practice — AppArmor Profile Enforcement
# Domain: System Hardening (10%)
#
# Enforce a prepared AppArmor profile on a specific worker node and deploy a Pod using it:
#
# 1. Apply the nginx-profile-2 AppArmor profile on the worker node node-01.
# 2. Edit the Pod manifest to reference this profile.
# 3. Deploy the Pod on node-01 and ensure the profile is applied correctly.
QEOF

cat > "$Q/01-apparmor-profile/LabSetUp.bash" << 'LEOF'
#!/bin/bash
set -euo pipefail

# Create AppArmor profile on the node
mkdir -p /etc/apparmor.d
cat > /etc/apparmor.d/nginx_apparmor << 'PROFILE'
#include <tunables/global>
profile nginx-profile-2 flags=(attach_disconnected) {
    #include <abstractions/base>
    file,
    # Deny all file writes.
    deny /** w,
}
PROFILE

# Create Pod manifest template (without AppArmor config — student must add it)
mkdir -p /home/candidate
cat > /home/candidate/nginx-pod.yaml << 'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  nodeName: node-01
  containers:
  - name: nginx-pod
    image: nginx:1.19.0
    ports:
    - containerPort: 80
YAML

echo "Lab setup complete. AppArmor profile at /etc/apparmor.d/nginx_apparmor"
echo "Pod manifest at /home/candidate/nginx-pod.yaml"
LEOF

cat > "$Q/01-apparmor-profile/SolutionNotes.bash" << 'SEOF'
#!/bin/bash
# Solution: AppArmor Profile Enforcement
#
# Step 1: SSH to the worker node and load the profile
# ssh node-01
# sudo -i
# apparmor_parser -q /etc/apparmor.d/nginx_apparmor
# aa-status | grep -i nginx-profile-2
# exit
#
# Step 2: Edit the Pod manifest to add AppArmor
#
# For Kubernetes >= 1.30 (securityContext):
#   spec:
#     containers:
#     - name: nginx-pod
#       securityContext:
#         appArmorProfile:
#           type: Localhost
#           localhostProfile: nginx-profile-2
#
# For Kubernetes < 1.30 (annotations):
#   metadata:
#     annotations:
#       container.apparmor.security.beta.kubernetes.io/nginx-pod: localhost/nginx-profile-2
#
# Step 3: Apply and verify
# kubectl create -f /home/candidate/nginx-pod.yaml
# kubectl get pods -o wide | grep nginx-pod
# kubectl exec -it nginx-pod -- touch /tmp/test  # should fail
SEOF

cat > "$Q/01-apparmor-profile/Verify.bash" << 'VEOF'
#!/bin/bash
echo "=== Verify: AppArmor Profile ==="
PASS=true

# Check profile is loaded
if ssh node-01 "aa-status 2>/dev/null | grep -q nginx-profile-2" 2>/dev/null || \
   aa-status 2>/dev/null | grep -q nginx-profile-2; then
  echo "[PASS] AppArmor profile nginx-profile-2 is loaded"
else
  echo "[FAIL] AppArmor profile nginx-profile-2 not found"
  PASS=false
fi

# Check Pod is running
if kubectl get pod nginx-pod -o jsonpath='{.status.phase}' 2>/dev/null | grep -q Running; then
  echo "[PASS] Pod nginx-pod is Running"
else
  echo "[FAIL] Pod nginx-pod is not Running"
  PASS=false
fi

# Check Pod is on node-01
NODE=$(kubectl get pod nginx-pod -o jsonpath='{.spec.nodeName}' 2>/dev/null)
if [ "$NODE" = "node-01" ]; then
  echo "[PASS] Pod is on node-01"
else
  echo "[FAIL] Pod is on $NODE, expected node-01"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
VEOF

#── Q02 ──────────────────────────────────────────────────────────────────────
cat > "$Q/02-networkpolicy-deny-all/Questions.bash" << 'QEOF'
# CKS Practice — Default Deny NetworkPolicy
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# Create a NetworkPolicy named deny-all in the testing namespace
# that blocks all ingress and egress traffic for all pods in the namespace.
QEOF

cat > "$Q/02-networkpolicy-deny-all/LabSetUp.bash" << 'LEOF'
#!/bin/bash
set -euo pipefail
kubectl create namespace testing --dry-run=client -o yaml | kubectl apply -f -
kubectl run web -n testing --image=nginx --labels="app=web"
kubectl run client -n testing --image=busybox --command -- sleep 3600
echo "Lab setup complete. Namespace: testing, Pods: web, client"
LEOF

cat > "$Q/02-networkpolicy-deny-all/SolutionNotes.bash" << 'SEOF'
#!/bin/bash
# Solution: Default Deny NetworkPolicy
#
# apiVersion: networking.k8s.io/v1
# kind: NetworkPolicy
# metadata:
#   name: deny-all
#   namespace: testing
# spec:
#   podSelector: {}
#   policyTypes:
#   - Ingress
#   - Egress
#
# kubectl apply -f netpol.yaml
# kubectl get netpol -n testing
# kubectl describe netpol deny-all -n testing
SEOF

cat > "$Q/02-networkpolicy-deny-all/Verify.bash" << 'VEOF'
#!/bin/bash
echo "=== Verify: Default Deny NetworkPolicy ==="
PASS=true

NP=$(kubectl get netpol deny-all -n testing -o jsonpath='{.metadata.name}' 2>/dev/null)
if [ "$NP" = "deny-all" ]; then
  echo "[PASS] NetworkPolicy deny-all exists in testing"
else
  echo "[FAIL] NetworkPolicy deny-all not found in testing"
  PASS=false
fi

TYPES=$(kubectl get netpol deny-all -n testing -o jsonpath='{.spec.policyTypes[*]}' 2>/dev/null)
if echo "$TYPES" | grep -q "Ingress" && echo "$TYPES" | grep -q "Egress"; then
  echo "[PASS] Policy covers both Ingress and Egress"
else
  echo "[FAIL] Policy types: $TYPES (need both Ingress and Egress)"
  PASS=false
fi

SEL=$(kubectl get netpol deny-all -n testing -o jsonpath='{.spec.podSelector}' 2>/dev/null)
if [ "$SEL" = "{}" ]; then
  echo "[PASS] podSelector is empty (applies to all pods)"
else
  echo "[FAIL] podSelector should be empty, got: $SEL"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
VEOF

#── Q03 ──────────────────────────────────────────────────────────────────────
cat > "$Q/03-serviceaccount-token/Questions.bash" << 'QEOF'
# CKS Practice — ServiceAccount Token Management
# Domain: Cluster Hardening (15%)
#
# A Pod nginx-pod is running in the default namespace and uses a token by default.
#
# 1. Modify the default ServiceAccount to disable automatic token mounting.
# 2. Create a Secret of type kubernetes.io/service-account-token that references
#    the default ServiceAccount.
# 3. Edit the Pod to:
#    - Use the default ServiceAccount.
#    - Mount the token from the Secret at /var/run/secrets/kubernetes.io/serviceaccount/token.
QEOF

cat > "$Q/03-serviceaccount-token/LabSetUp.bash" << 'LEOF'
#!/bin/bash
set -euo pipefail
kubectl run nginx-pod --image=nginx --restart=Never --dry-run=client -o yaml | kubectl apply -f -
kubectl wait --for=condition=Ready pod/nginx-pod --timeout=60s 2>/dev/null || true
echo "Lab setup complete. Pod nginx-pod running in default namespace."
LEOF

cat > "$Q/03-serviceaccount-token/SolutionNotes.bash" << 'SEOF'
#!/bin/bash
# Solution: ServiceAccount Token Management
#
# Step 1: Disable automount on default SA
# kubectl patch sa default -n default -p '{"automountServiceAccountToken": false}'
#
# Step 2: Create the Secret
# cat <<EOF | kubectl apply -f -
# apiVersion: v1
# kind: Secret
# metadata:
#   name: default-sa-token
#   annotations:
#     kubernetes.io/service-account.name: "default"
# type: kubernetes.io/service-account-token
# EOF
#
# Step 3: Recreate Pod with manual volume mount
# kubectl delete pod nginx-pod
# cat <<EOF | kubectl apply -f -
# apiVersion: v1
# kind: Pod
# metadata:
#   name: nginx-pod
# spec:
#   serviceAccountName: default
#   automountServiceAccountToken: false
#   containers:
#   - name: nginx
#     image: nginx
#     volumeMounts:
#     - name: token-vol
#       mountPath: /var/run/secrets/kubernetes.io/serviceaccount/
#       readOnly: true
#   volumes:
#   - name: token-vol
#     secret:
#       secretName: default-sa-token
# EOF
#
# Verify: kubectl exec -it nginx-pod -- cat /var/run/secrets/kubernetes.io/serviceaccount/token
SEOF

cat > "$Q/03-serviceaccount-token/Verify.bash" << 'VEOF'
#!/bin/bash
echo "=== Verify: ServiceAccount Token Management ==="
PASS=true

AUTOMOUNT=$(kubectl get sa default -o jsonpath='{.automountServiceAccountToken}' 2>/dev/null)
if [ "$AUTOMOUNT" = "false" ]; then
  echo "[PASS] default SA has automountServiceAccountToken: false"
else
  echo "[FAIL] default SA automountServiceAccountToken is not false"
  PASS=false
fi

SECRET_TYPE=$(kubectl get secret default-sa-token -o jsonpath='{.type}' 2>/dev/null)
if [ "$SECRET_TYPE" = "kubernetes.io/service-account-token" ]; then
  echo "[PASS] Secret default-sa-token exists with correct type"
else
  echo "[FAIL] Secret default-sa-token not found or wrong type"
  PASS=false
fi

TOKEN=$(kubectl exec nginx-pod -- cat /var/run/secrets/kubernetes.io/serviceaccount/token 2>/dev/null)
if [ -n "$TOKEN" ]; then
  echo "[PASS] Token is mounted in the Pod"
else
  echo "[FAIL] Token not found at expected mount path"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
VEOF

#── Q04 ──────────────────────────────────────────────────────────────────────
cat > "$Q/04-secure-api-server/Questions.bash" << 'QEOF'
# CKS Practice — Re-secure the API Server
# Domain: Cluster Hardening (15%)
#
# The cluster's API server was temporarily configured to allow
# unauthenticated + unauthorized access (anonymous user had cluster-admin).
#
# Re-secure the cluster so that only authenticated and authorized REST requests are allowed.
#
# Requirements:
# 1. Use authorization mode Node,RBAC.
# 2. Use admission controller NodeRestriction.
# 3. Disable --anonymous-auth.
# 4. Remove ClusterRoleBinding that grants access to system:anonymous.
# 5. After the fix, use the original kubeconfig /etc/kubernetes/admin.conf.
QEOF

cat > "$Q/04-secure-api-server/LabSetUp.bash" << 'LEOF'
#!/bin/bash
set -euo pipefail

# Create an insecure ClusterRoleBinding for anonymous access
kubectl create clusterrolebinding system:anonymous --clusterrole=cluster-admin --user=system:anonymous \
  --dry-run=client -o yaml | kubectl apply -f -

# Modify API server to be insecure (backup first)
MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"
cp "$MANIFEST" /tmp/kube-apiserver-backup.yaml

# Set insecure flags
sed -i 's/--authorization-mode=.*/--authorization-mode=AlwaysAllow/' "$MANIFEST"
sed -i '/--anonymous-auth/d' "$MANIFEST"
sed -i '/--enable-admission-plugins/s/NodeRestriction/AlwaysAdmit/' "$MANIFEST"

echo "Lab setup complete. API server is now insecure. Fix it."
echo "Backup at /tmp/kube-apiserver-backup.yaml (don't peek!)"
LEOF

cat > "$Q/04-secure-api-server/SolutionNotes.bash" << 'SEOF'
#!/bin/bash
# Solution: Re-secure the API Server
#
# Step 1: Edit /etc/kubernetes/manifests/kube-apiserver.yaml
#   - --authorization-mode=Node,RBAC
#   - --enable-admission-plugins=NodeRestriction
#   - --anonymous-auth=false
#   - --client-ca-file=/etc/kubernetes/pki/ca.crt   (should already be there)
#
# Step 2: Remove anonymous ClusterRoleBinding
#   kubectl delete clusterrolebinding system:anonymous
#
# Step 3: Wait for API server to restart (~30s)
#   kubectl get pods -n kube-system --kubeconfig /etc/kubernetes/admin.conf
SEOF

cat > "$Q/04-secure-api-server/Verify.bash" << 'VEOF'
#!/bin/bash
echo "=== Verify: API Server Security ==="
PASS=true

MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"

if grep -q 'authorization-mode=Node,RBAC' "$MANIFEST"; then
  echo "[PASS] Authorization mode is Node,RBAC"
else
  echo "[FAIL] Authorization mode is not Node,RBAC"
  PASS=false
fi

if grep -q 'anonymous-auth=false' "$MANIFEST"; then
  echo "[PASS] Anonymous auth is disabled"
else
  echo "[FAIL] Anonymous auth is not disabled"
  PASS=false
fi

if grep -q 'NodeRestriction' "$MANIFEST"; then
  echo "[PASS] NodeRestriction admission plugin enabled"
else
  echo "[FAIL] NodeRestriction not found"
  PASS=false
fi

if ! kubectl get clusterrolebinding system:anonymous &>/dev/null; then
  echo "[PASS] Anonymous ClusterRoleBinding removed"
else
  echo "[FAIL] Anonymous ClusterRoleBinding still exists"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
VEOF

#── Q05 ──────────────────────────────────────────────────────────────────────
cat > "$Q/05-audit-logging/Questions.bash" << 'QEOF'
# CKS Practice — Audit Logging
# Domain: Monitoring, Logging and Runtime Security (20%)
#
# Enable Kubernetes audit logging with custom retention and policy rules:
#
# 1. Store audit logs at /var/log/kubernetes-logs.log.
# 2. Retain logs for 5 days, maximum 10 old files, 100 MB per file.
# 3. Extend audit policy to:
#    - Log CronJob changes at RequestResponse level.
#    - Log request bodies for deployments in kube-system namespace.
#    - Log all other core and extensions resources at Request level.
#    - Exclude watch requests by system:kube-proxy on endpoints or services.
QEOF

cat > "$Q/05-audit-logging/LabSetUp.bash" << 'LEOF'
#!/bin/bash
set -euo pipefail

# Create a minimal audit policy (student must extend it)
mkdir -p /etc/audit
cat > /etc/audit/audit-policy.yaml << 'YAML'
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  - level: None
YAML

echo "Lab setup complete."
echo "Base audit policy at /etc/audit/audit-policy.yaml"
echo "API server manifest at /etc/kubernetes/manifests/kube-apiserver.yaml"
LEOF

cat > "$Q/05-audit-logging/SolutionNotes.bash" << 'SEOF'
#!/bin/bash
# Solution: Audit Logging
#
# Step 1: Edit /etc/audit/audit-policy.yaml
#
# apiVersion: audit.k8s.io/v1
# kind: Policy
# rules:
#   - level: RequestResponse
#     resources:
#       - group: "batch"
#         resources: ["cronjobs"]
#   - level: Request
#     namespaces: ["kube-system"]
#     resources:
#       - group: "apps"
#         resources: ["deployments"]
#   - level: Request
#     resources:
#       - group: ""
#       - group: "extensions"
#   - level: None
#     users: ["system:kube-proxy"]
#     verbs: ["watch"]
#     resources:
#       - group: ""
#         resources: ["endpoints", "services"]
#
# Step 2: Edit /etc/kubernetes/manifests/kube-apiserver.yaml
#   Add flags:
#     - --audit-policy-file=/etc/audit/audit-policy.yaml
#     - --audit-log-path=/var/log/kubernetes-logs.log
#     - --audit-log-maxage=5
#     - --audit-log-maxbackup=10
#     - --audit-log-maxsize=100
#
#   Add volumeMounts + volumes for:
#     /etc/audit/audit-policy.yaml (type: File)
#     /var/log/ (type: DirectoryOrCreate)
#
# Step 3: Wait for API server restart, then verify:
#   tail -f /var/log/kubernetes-logs.log
SEOF

cat > "$Q/05-audit-logging/Verify.bash" << 'VEOF'
#!/bin/bash
echo "=== Verify: Audit Logging ==="
PASS=true

MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"

if grep -q 'audit-log-path=/var/log/kubernetes-logs.log' "$MANIFEST"; then
  echo "[PASS] Audit log path configured"
else
  echo "[FAIL] Audit log path not set"
  PASS=false
fi

if grep -q 'audit-log-maxage=5' "$MANIFEST"; then
  echo "[PASS] Log retention set to 5 days"
else
  echo "[FAIL] Log retention not set to 5"
  PASS=false
fi

if grep -q 'audit-log-maxbackup=10' "$MANIFEST"; then
  echo "[PASS] Max backup files set to 10"
else
  echo "[FAIL] Max backup not set to 10"
  PASS=false
fi

if [ -f /etc/audit/audit-policy.yaml ]; then
  if grep -q 'RequestResponse' /etc/audit/audit-policy.yaml && \
     grep -q 'cronjobs' /etc/audit/audit-policy.yaml; then
    echo "[PASS] Audit policy has CronJob rule"
  else
    echo "[FAIL] Audit policy missing CronJob RequestResponse rule"
    PASS=false
  fi
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
VEOF

#── Q06 ──────────────────────────────────────────────────────────────────────
cat > "$Q/06-dockerfile-pod-fixes/Questions.bash" << 'QEOF'
# CKS Practice — Dockerfile and Pod Security Fixes
# Domain: System Hardening (10%)
#
# You are given a Dockerfile and a Pod manifest. Both contain security violations.
#
# Rules:
# - Fix two issues in the Dockerfile.
# - Fix two issues in the Pod manifest.
# - Do not add or remove fields — only edit existing ones.
# - When a non-root user is needed, use test-user with UID 5375.
#
# Files are at /home/candidate/06/
QEOF

cat > "$Q/06-dockerfile-pod-fixes/LabSetUp.bash" << 'LEOF'
#!/bin/bash
set -euo pipefail
mkdir -p /home/candidate/06

cat > /home/candidate/06/Dockerfile << 'DEOF'
FROM ubuntu:latest
RUN apt-get update -y
RUN apt-get install nginx -y
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
USER ROOT
DEOF

cat > /home/candidate/06/pod.yaml << 'YEOF'
apiVersion: v1
kind: Pod
metadata:
  name: security-context-demo-2
spec:
  securityContext:
    runAsUser: 1000
  containers:
  - name: security-context-demo-2
    image: gcr.io/google-samples/node-hello:1.0
    securityContext:
      runAsUser: 0
      privileged: true
      allowPrivilegeEscalation: false
YEOF

echo "Lab setup complete. Files at /home/candidate/06/"
LEOF

cat > "$Q/06-dockerfile-pod-fixes/SolutionNotes.bash" << 'SEOF'
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
SEOF

cat > "$Q/06-dockerfile-pod-fixes/Verify.bash" << 'VEOF'
#!/bin/bash
echo "=== Verify: Dockerfile and Pod Fixes ==="
PASS=true

DF="/home/candidate/06/Dockerfile"
POD="/home/candidate/06/pod.yaml"

if ! grep -q 'ubuntu:latest' "$DF"; then
  echo "[PASS] Dockerfile no longer uses :latest"
else
  echo "[FAIL] Dockerfile still uses ubuntu:latest"
  PASS=false
fi

if grep -qi 'USER test-user\|USER 5375\|USER nobody' "$DF" && ! grep -qi 'USER ROOT' "$DF"; then
  echo "[PASS] Dockerfile uses non-root user"
else
  echo "[FAIL] Dockerfile still runs as ROOT"
  PASS=false
fi

if grep -q 'runAsUser: 5375' "$POD"; then
  echo "[PASS] Pod uses runAsUser 5375"
else
  echo "[FAIL] Pod runAsUser not set to 5375"
  PASS=false
fi

if grep -q 'privileged: false' "$POD"; then
  echo "[PASS] Pod privileged is false"
else
  echo "[FAIL] Pod still has privileged: true"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
VEOF

echo "Generated Test 1 questions 01-06."

#── Q07-16 (Test 1 remaining) ───────────────────────────────────────────────
# Generate the remaining Test 1 questions with simpler setup

for q in 07-kube-bench 08-encryption-at-rest 09-stateless-immutable-pods 10-runtimeclass-gvisor \
         11-imagepolicy-webhook 12-docker-sock-removal 13-istio-mtls 14-pod-security-admission \
         15-worker-node-upgrade 16-falco-devmem; do
  dir="$Q/$q"

  # Create minimal LabSetUp
  cat > "$dir/LabSetUp.bash" << 'LEOF'
#!/bin/bash
set -euo pipefail
echo "Lab setup complete. See Questions.bash for task details."
LEOF

  # Create minimal Verify
  cat > "$dir/Verify.bash" << 'VEOF'
#!/bin/bash
echo "=== Manual verification required for this question ==="
echo "Review the solution notes and check your work."
VEOF
done

# Q07 — kube-bench
cat > "$Q/07-kube-bench/Questions.bash" << 'QEOF'
# CKS Practice — kube-bench Fixes
# Domain: Cluster Setup (15%)
#
# Fix multiple security violations identified by kube-bench.
#
# API Server:
#   - Enable RotateKubeletServerCertificate.
#   - Enable admission plugin PodSecurityPolicy.
#   - Set --kubelet-certificate-authority argument.
#
# Kubelet:
#   - Disable anonymous authentication.
#   - Set authorization-mode to Webhook.
#
# ETCD:
#   - Ensure --auto-tls is not true.
#   - Ensure --peer-auto-tls is not true.
QEOF

cat > "$Q/07-kube-bench/SolutionNotes.bash" << 'SEOF'
#!/bin/bash
# Solution: kube-bench Fixes
#
# Run: kube-bench run --targets=master,node,etcd
#
# API Server (/etc/kubernetes/manifests/kube-apiserver.yaml):
#   - --feature-gates=RotateKubeletServerCertificate=true
#   - --enable-admission-plugins=...,PodSecurityPolicy
#   - --kubelet-certificate-authority=/etc/kubernetes/pki/ca.crt
#
# Kubelet (/var/lib/kubelet/config.yaml):
#   authentication:
#     anonymous:
#       enabled: false
#     webhook:
#       enabled: true
#   authorization:
#     mode: Webhook
#   sudo systemctl daemon-reexec && sudo systemctl restart kubelet
#
# ETCD (/etc/kubernetes/manifests/etcd.yaml):
#   - --auto-tls=false
#   - --peer-auto-tls=false
#
# Verify: kube-bench run --targets=master,node,etcd
SEOF

# Q08 — encryption at rest
cat > "$Q/08-encryption-at-rest/Questions.bash" << 'QEOF'
# CKS Practice — Encryption at Rest
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# By default, Kubernetes stores Secrets in etcd in plaintext.
#
# Enable encryption at rest for Secrets using an EncryptionConfiguration
# manifest with AES-CBC and identity providers.
# Ensure all secrets are encrypted in etcd.
QEOF

cat > "$Q/08-encryption-at-rest/LabSetUp.bash" << 'LEOF'
#!/bin/bash
set -euo pipefail
mkdir -p /etc/kubernetes/enc
kubectl create secret generic test-unencrypted -n default --from-literal=key=plaintext 2>/dev/null || true
echo "Lab setup complete. A test secret exists in default namespace."
LEOF

cat > "$Q/08-encryption-at-rest/SolutionNotes.bash" << 'SEOF'
#!/bin/bash
# Solution: Encryption at Rest
#
# Step 1: Generate key
#   head -c 32 /dev/urandom | base64
#
# Step 2: Create /etc/kubernetes/enc/enc.yaml
#   apiVersion: apiserver.config.k8s.io/v1
#   kind: EncryptionConfiguration
#   resources:
#     - resources:
#         - secrets
#       providers:
#         - aescbc:
#             keys:
#               - name: key1
#                 secret: <base64-key>
#         - identity: {}
#
# Step 3: Edit kube-apiserver manifest
#   - --encryption-provider-config=/etc/kubernetes/enc/enc.yaml
#   volumeMounts: mountPath: /etc/kubernetes/enc
#   volumes: hostPath: /etc/kubernetes/enc
#
# Step 4: Re-encrypt existing secrets
#   kubectl get secrets --all-namespaces -o json | kubectl replace -f -
#
# Step 5: Verify
#   ETCDCTL_API=3 etcdctl \
#     --cacert=/etc/kubernetes/pki/etcd/ca.crt \
#     --cert=/etc/kubernetes/pki/etcd/server.crt \
#     --key=/etc/kubernetes/pki/etcd/server.key \
#     get /registry/secrets/default/test-unencrypted | hexdump -C
SEOF

# Q09 — stateless immutable pods
cat > "$Q/09-stateless-immutable-pods/Questions.bash" << 'QEOF'
# CKS Practice — Stateless and Immutable Pods
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# Ensure all Pods in the prod namespace follow best practices of being
# stateless and immutable. Identify and delete any Pods that store data
# in container volumes (stateful) or are configured as privileged/with
# writable root filesystems (not immutable).
QEOF

cat > "$Q/09-stateless-immutable-pods/LabSetUp.bash" << 'LEOF'
#!/bin/bash
set -euo pipefail
kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f -

# Compliant pod
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  namespace: prod
spec:
  containers:
  - name: nginx
    image: nginx
    securityContext:
      readOnlyRootFilesystem: true
      privileged: false
EOF

# Non-immutable pod (privileged)
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: app
  namespace: prod
spec:
  containers:
  - name: app
    image: nginx
    securityContext:
      privileged: true
      readOnlyRootFilesystem: false
EOF

# Stateful pod (hostPath)
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: gcc
  namespace: prod
spec:
  containers:
  - name: gcc
    image: nginx
    volumeMounts:
    - mountPath: /data
      name: host-vol
  volumes:
  - name: host-vol
    hostPath:
      path: /tmp/data
EOF

echo "Lab setup complete. Namespace: prod, Pods: frontend, app, gcc"
LEOF

cat > "$Q/09-stateless-immutable-pods/SolutionNotes.bash" << 'SEOF'
#!/bin/bash
# Solution: Stateless and Immutable Pods
#
# Inspect each pod:
#   kubectl get pod/app -n prod -o yaml | grep -E 'privileged|readOnlyRootFilesystem'
#   kubectl get pods -n prod -o jsonpath="{range .items[*]}{.metadata.name}{': '}{.spec.volumes[*].name}{'\n'}{end}"
#
# Delete non-compliant pods:
#   kubectl delete --grace-period=0 --force pod app -n prod
#   kubectl delete --grace-period=0 --force pod gcc -n prod
#
# frontend should remain (compliant)
SEOF

cat > "$Q/09-stateless-immutable-pods/Verify.bash" << 'VEOF'
#!/bin/bash
echo "=== Verify: Stateless and Immutable Pods ==="
PASS=true

# frontend should exist
if kubectl get pod frontend -n prod &>/dev/null; then
  echo "[PASS] Pod frontend exists (compliant)"
else
  echo "[FAIL] Pod frontend was deleted (it was compliant!)"
  PASS=false
fi

# app should be deleted
if ! kubectl get pod app -n prod &>/dev/null; then
  echo "[PASS] Pod app deleted (was privileged)"
else
  echo "[FAIL] Pod app still exists (privileged=true)"
  PASS=false
fi

# gcc should be deleted
if ! kubectl get pod gcc -n prod &>/dev/null; then
  echo "[PASS] Pod gcc deleted (had hostPath)"
else
  echo "[FAIL] Pod gcc still exists (had hostPath volume)"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
VEOF

# Q10 — runtimeclass gvisor
cat > "$Q/10-runtimeclass-gvisor/Questions.bash" << 'QEOF'
# CKS Practice — RuntimeClass with gVisor
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# The cluster uses containerd with runc as the default runtime.
# It has been prepared to support runsc (gVisor).
#
# 1. Create a RuntimeClass named sandboxed using runsc.
# 2. Update all Pods in the server namespace to use this runtime.
QEOF

cat > "$Q/10-runtimeclass-gvisor/LabSetUp.bash" << 'LEOF'
#!/bin/bash
set -euo pipefail
kubectl create namespace server --dry-run=client -o yaml | kubectl apply -f -
kubectl create deployment workload1 -n server --image=nginx --replicas=1
kubectl create deployment workload2 -n server --image=nginx --replicas=1
kubectl create deployment workload3 -n server --image=nginx --replicas=1
mkdir -p /home/candidate/10
echo "Lab setup complete. Namespace: server, Deployments: workload1-3"
LEOF

cat > "$Q/10-runtimeclass-gvisor/SolutionNotes.bash" << 'SEOF'
#!/bin/bash
# Solution: RuntimeClass with gVisor
#
# Step 1: Create RuntimeClass
# cat <<EOF | kubectl create -f -
# apiVersion: node.k8s.io/v1
# kind: RuntimeClass
# metadata:
#   name: sandboxed
# handler: runsc
# EOF
#
# Step 2: Edit each deployment
# kubectl edit deploy -n server workload1
# kubectl edit deploy -n server workload2
# kubectl edit deploy -n server workload3
# Add under spec.template.spec:
#   runtimeClassName: sandboxed
#
# Verify:
# kubectl get pods -n server -o jsonpath="{range .items[*]}{.metadata.name}{': '}{.spec.runtimeClassName}{'\n'}{end}"
SEOF

# Q11 — imagepolicy webhook
cat > "$Q/11-imagepolicy-webhook/Questions.bash" << 'QEOF'
# CKS Practice — ImagePolicyWebhook
# Domain: Supply Chain Security (20%)
#
# The cluster has a container image scanner webhook but its configuration is incomplete.
# Configuration is in /etc/kubernetes/confcontrol directory.
#
# 1. Enable the ImagePolicy admission plugin.
# 2. Set it to deny all non-compliant images (implicit deny).
# 3. Test by deploying a Pod using the latest image tag.
QEOF

cat > "$Q/11-imagepolicy-webhook/LabSetUp.bash" << 'LEOF'
#!/bin/bash
set -euo pipefail
mkdir -p /etc/kubernetes/confcontrol

cat > /etc/kubernetes/confcontrol/admission_configuration.yaml << 'YAML'
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
  - name: ImagePolicyWebhook
    configuration:
      imagePolicy:
        kubeConfigFile: /etc/kubernetes/confcontrol/kubeconfig.yaml
        allowTTL: 50
        denyTTL: 50
        retryBackoff: 500
        defaultAllow: true
YAML

cat > /etc/kubernetes/confcontrol/kubeconfig.yaml << 'YAML'
apiVersion: v1
kind: Config
clusters:
- name: test-server
  cluster:
    server: https://test-server.local:8081/image_policy
contexts:
- name: webhook-context
  context:
    cluster: test-server
    user: apiserver
current-context: webhook-context
YAML

echo "Lab setup complete. Config at /etc/kubernetes/confcontrol/"
echo "NOTE: defaultAllow is set to true — you need to change it to false."
LEOF

cat > "$Q/11-imagepolicy-webhook/SolutionNotes.bash" << 'SEOF'
#!/bin/bash
# Solution: ImagePolicyWebhook
#
# Step 1: Fix admission_configuration.yaml
#   Change: defaultAllow: true  ->  defaultAllow: false
#
# Step 2: Edit kube-apiserver manifest
#   - --enable-admission-plugins=NodeRestriction,ImagePolicyWebhook
#   - --admission-control-config-file=/etc/kubernetes/confcontrol/admission_configuration.yaml
#
#   Add volume mount for /etc/kubernetes/confcontrol
#
# Step 3: Test
#   kubectl run pod-latest --image=nginx:latest
#   # Should be denied
SEOF

# Q12 — docker sock removal
cat > "$Q/12-docker-sock-removal/Questions.bash" << 'QEOF'
# CKS Practice — Remove docker.sock Mount
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# A Pod in namespace dev-ops is mounting /var/run/docker.sock from the host.
# This gives the container privileged access to the Docker daemon.
#
# 1. Identify the Pod(s) mounting docker.sock.
# 2. Update their Deployment(s) to remove the volume mount.
# 3. Verify containers can no longer access /var/run/docker.sock.
QEOF

cat > "$Q/12-docker-sock-removal/LabSetUp.bash" << 'LEOF'
#!/bin/bash
set -euo pipefail
kubectl create namespace dev-ops --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: docker-hacker
  namespace: dev-ops
spec:
  replicas: 1
  selector:
    matchLabels:
      app: docker-hacker
  template:
    metadata:
      labels:
        app: docker-hacker
    spec:
      containers:
      - name: container1
        image: nginx
        volumeMounts:
        - name: dockersock
          mountPath: /var/run/docker.sock
      volumes:
      - name: dockersock
        hostPath:
          path: /var/run/docker.sock
EOF

echo "Lab setup complete. Namespace: dev-ops, Deployment: docker-hacker"
LEOF

cat > "$Q/12-docker-sock-removal/SolutionNotes.bash" << 'SEOF'
#!/bin/bash
# Solution: Remove docker.sock Mount
#
# kubectl get pods -n dev-ops -o yaml | grep -A 3 "docker.sock"
# kubectl edit deploy docker-hacker -n dev-ops
#
# Remove from volumeMounts:
#   - mountPath: /var/run/docker.sock
#     name: dockersock
#
# Remove from volumes:
#   - name: dockersock
#     hostPath:
#       path: /var/run/docker.sock
#
# Verify:
# kubectl rollout status deploy/docker-hacker -n dev-ops
# kubectl exec -it <pod> -n dev-ops -- ls -l /var/run/docker.sock
# Should say: No such file or directory
SEOF

cat > "$Q/12-docker-sock-removal/Verify.bash" << 'VEOF'
#!/bin/bash
echo "=== Verify: docker.sock Removal ==="
PASS=true

MOUNTS=$(kubectl get deploy docker-hacker -n dev-ops -o yaml 2>/dev/null | grep "docker.sock" || true)
if [ -z "$MOUNTS" ]; then
  echo "[PASS] docker.sock mount removed from deployment"
else
  echo "[FAIL] docker.sock still mounted in deployment"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
VEOF

# Q13 — istio mtls
cat > "$Q/13-istio-mtls/Questions.bash" << 'QEOF'
# CKS Practice — Istio mTLS
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# Enable Istio Mutual TLS (mTLS) in STRICT mode for all workloads
# in the namespace payments.
#
# Before enforcing mTLS, verify that automatic Istio Sidecar Injection
# is enabled for the namespace.
QEOF

cat > "$Q/13-istio-mtls/SolutionNotes.bash" << 'SEOF'
#!/bin/bash
# Solution: Istio mTLS
#
# Step 1: Enable sidecar injection
# kubectl label namespace payments istio-injection=enabled --overwrite
#
# Step 2: Create PeerAuthentication
# cat <<EOF | kubectl apply -f -
# apiVersion: security.istio.io/v1
# kind: PeerAuthentication
# metadata:
#   name: payments-mtls-strict
#   namespace: payments
# spec:
#   mtls:
#     mode: STRICT
# EOF
#
# Step 3: Restart pods if needed
# kubectl rollout restart deployment -n payments
#
# Verify:
# kubectl get peerauthentication -n payments
SEOF

# Q14 — pod security admission
cat > "$Q/14-pod-security-admission/Questions.bash" << 'QEOF'
# CKS Practice — Pod Security Admission
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# The namespace secure-team is configured with Pod Security Admission
# enforcing the restricted profile.
#
# A Deployment at /home/masters/insecure-deployment.yaml fails to start
# because it violates the restricted Pod Security Standard.
#
# Edit the YAML to fix each violation and get the Deployment running.
QEOF

cat > "$Q/14-pod-security-admission/LabSetUp.bash" << 'LEOF'
#!/bin/bash
set -euo pipefail
kubectl create namespace secure-team --dry-run=client -o yaml | kubectl apply -f -
kubectl label ns secure-team pod-security.kubernetes.io/enforce=restricted --overwrite

mkdir -p /home/masters
cat > /home/masters/insecure-deployment.yaml << 'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  namespace: secure-team
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: nginx:1.23
        ports:
        - containerPort: 80
        securityContext:
          privileged: true
          runAsUser: 0
          capabilities:
            add: ["NET_ADMIN"]
        volumeMounts:
        - mountPath: /data
          name: host-data
      volumes:
      - name: host-data
        hostPath:
          path: /tmp
YAML

echo "Lab setup complete. Namespace: secure-team (restricted enforcement)"
echo "Deployment manifest at /home/masters/insecure-deployment.yaml"
LEOF

cat > "$Q/14-pod-security-admission/SolutionNotes.bash" << 'SEOF'
#!/bin/bash
# Solution: Pod Security Admission
#
# Fix the deployment manifest:
#   privileged: true        -> (remove or set false)
#   runAsUser: 0            -> runAsUser: 65535
#   capabilities.add: NET_ADMIN -> capabilities.drop: ["ALL"]
#   hostPath volume         -> emptyDir: {}
#
# Add missing fields:
#   runAsNonRoot: true
#   allowPrivilegeEscalation: false
#   readOnlyRootFilesystem: true
#
# kubectl apply -f /home/masters/insecure-deployment.yaml
SEOF

cat > "$Q/14-pod-security-admission/Verify.bash" << 'VEOF'
#!/bin/bash
echo "=== Verify: Pod Security Admission ==="
PASS=true

READY=$(kubectl get deploy webapp -n secure-team -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [ "$READY" = "1" ]; then
  echo "[PASS] Deployment webapp is running in secure-team"
else
  echo "[FAIL] Deployment webapp is not ready (readyReplicas: $READY)"
  PASS=false
fi

$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
VEOF

# Q15 — worker node upgrade
cat > "$Q/15-worker-node-upgrade/Questions.bash" << 'QEOF'
# CKS Practice — Worker Node Upgrade
# Domain: Cluster Hardening (15%)
#
# One worker node (worker-1) is running v1.32.0.
# The control plane has been upgraded to v1.33.0.
#
# Upgrade worker-1 to match the control plane version.
QEOF

cat > "$Q/15-worker-node-upgrade/SolutionNotes.bash" << 'SEOF'
#!/bin/bash
# Solution: Worker Node Upgrade
#
# kubectl drain worker-1 --ignore-daemonsets
# ssh worker-1
# sudo -i
#
# # Update apt repo
# vim /etc/apt/sources.list.d/kubernetes.list
# # Change to v1.33
#
# sudo apt-mark unhold kubeadm
# sudo apt-get update && sudo apt-get install -y kubeadm='1.33.0-0.0'
# sudo apt-mark hold kubeadm
# sudo kubeadm upgrade node
#
# sudo apt-mark unhold kubelet kubectl
# sudo apt-get install -y kubelet='1.33.0-0.0' kubectl='1.33.0-0.0'
# sudo apt-mark hold kubelet kubectl
#
# sudo systemctl daemon-reload
# sudo systemctl restart kubelet
# exit
#
# kubectl uncordon worker-1
# kubectl get nodes
SEOF

# Q16 — falco devmem
cat > "$Q/16-falco-devmem/Questions.bash" << 'QEOF'
# CKS Practice — Falco: Detect /dev/mem Access
# Domain: Monitoring, Logging and Runtime Security (20%)
#
# A malicious container is attempting to access /dev/mem.
# This represents direct access to physical memory and may lead to
# privilege escalation or kernel bypass.
#
# 1. Use Falco to detect the malicious Pod and its Deployment.
# 2. Scale the Deployment replicas to 0 to stop the workload.
QEOF

cat > "$Q/16-falco-devmem/SolutionNotes.bash" << 'SEOF'
#!/bin/bash
# Solution: Falco — Detect /dev/mem Access
#
# Custom Falco rule (save as rule.yaml):
# - rule: read write below /dev/mem
#   desc: An attempt to read or write to /dev/mem
#   condition: >
#     ((evt.is_open_read=true or evt.is_open_write=true) and fd.name contains /dev/mem)
#   output: "Process %proc.name accessed /dev/mem (pod_name=%k8s.pod.name namespace=%k8s.ns.name)"
#   priority: WARNING
#   tags: [security]
#
# Run: falco -r rule.yaml | grep -i 'dev/mem'
#
# From output, identify the Pod -> Deployment
# kubectl scale deployment mem-hacker --replicas=0 -n default
SEOF

echo "Generated all Test 1 questions (01-16)."

###############################################################################
# TEST 2-4: Generate remaining questions with same pattern
###############################################################################

# For brevity, generate the remaining questions with Questions + SolutionNotes
# Many share setup patterns with Test 1

# Test 2 questions that are unique (not duplicates of Test 1)

cat > "$Q/17-audit-logging-extended/Questions.bash" << 'QEOF'
# CKS Practice — Audit Logging (Extended Policy)
# Domain: Monitoring, Logging and Runtime Security (20%)
#
# Store audit logs at /var/log/kubernetes-logs.log.
# Retain 12 days, max 8 files, rotate at 200MB.
# Extend policy:
#   - Log namespace changes at RequestResponse.
#   - Log secret changes in kube-system at Request.
#   - Log core and extensions at Request.
#   - Log pods/portforward, services/proxy at Metadata.
#   - Omit RequestReceived stage.
#   - Default all others at Metadata.
QEOF

cat > "$Q/17-audit-logging-extended/LabSetUp.bash" << 'LEOF'
#!/bin/bash
set -euo pipefail
mkdir -p /etc/audit
cat > /etc/audit/audit-policy.yaml << 'YAML'
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  - level: None
YAML
echo "Lab setup complete. Edit /etc/audit/audit-policy.yaml and kube-apiserver manifest."
LEOF

cat > "$Q/17-audit-logging-extended/SolutionNotes.bash" << 'SEOF'
#!/bin/bash
# Solution: Audit Logging Extended
#
# apiVersion: audit.k8s.io/v1
# kind: Policy
# omitStages: ["RequestReceived"]
# rules:
#   - level: RequestResponse
#     resources: [{group: "", resources: ["namespaces"]}]
#   - level: Request
#     namespaces: ["kube-system"]
#     resources: [{group: "", resources: ["secrets"]}]
#   - level: Request
#     resources: [{group: ""}, {group: "extensions"}]
#   - level: Metadata
#     resources: [{group: "", resources: ["pods/portforward", "services/proxy"]}]
#   - level: Metadata
#
# kube-apiserver flags:
#   --audit-log-maxage=12 --audit-log-maxbackup=8 --audit-log-maxsize=200
SEOF

cat > "$Q/17-audit-logging-extended/Verify.bash" << 'VEOF'
#!/bin/bash
echo "=== Verify: Audit Logging Extended ==="
PASS=true
M="/etc/kubernetes/manifests/kube-apiserver.yaml"
grep -q 'audit-log-maxage=12' "$M" && echo "[PASS] maxage=12" || { echo "[FAIL] maxage"; PASS=false; }
grep -q 'audit-log-maxbackup=8' "$M" && echo "[PASS] maxbackup=8" || { echo "[FAIL] maxbackup"; PASS=false; }
grep -q 'audit-log-maxsize=200' "$M" && echo "[PASS] maxsize=200" || { echo "[FAIL] maxsize"; PASS=false; }
grep -q 'omitStages' /etc/audit/audit-policy.yaml && echo "[PASS] omitStages present" || { echo "[FAIL] omitStages"; PASS=false; }
$PASS && echo "=== ALL CHECKS PASSED ===" || echo "=== SOME CHECKS FAILED ==="
VEOF

# Trivy scanning
cat > "$Q/18-trivy-scanning/Questions.bash" << 'QEOF'
# CKS Practice — Trivy Image Scanning
# Domain: Supply Chain Security (20%)
#
# Scan these images for HIGH/CRITICAL vulnerabilities:
#   ubuntu:18.04, registry.k8s.io/kube-apiserver:v1.24.0,
#   registry.k8s.io/kube-scheduler:v1.23.0, postgres:12, httpd:2.4.49
#
# Store all scan output in /opt/trivy-vulnerable.txt.
QEOF
cat > "$Q/18-trivy-scanning/LabSetUp.bash" << 'LEOF'
#!/bin/bash
echo "Lab setup complete. Ensure trivy is installed (run scripts/setup-tools.sh)."
LEOF
cat > "$Q/18-trivy-scanning/SolutionNotes.bash" << 'SEOF'
#!/bin/bash
# trivy image --severity HIGH,CRITICAL --output /opt/trivy-vulnerable.txt ubuntu:18.04
# trivy image --severity HIGH,CRITICAL registry.k8s.io/kube-apiserver:v1.24.0 >> /opt/trivy-vulnerable.txt
# trivy image --severity HIGH,CRITICAL registry.k8s.io/kube-scheduler:v1.23.0 >> /opt/trivy-vulnerable.txt
# trivy image --severity HIGH,CRITICAL postgres:12 >> /opt/trivy-vulnerable.txt
# trivy image --severity HIGH,CRITICAL httpd:2.4.49 >> /opt/trivy-vulnerable.txt
SEOF
cat > "$Q/18-trivy-scanning/Verify.bash" << 'VEOF'
#!/bin/bash
echo "=== Verify: Trivy Scanning ==="
[ -f /opt/trivy-vulnerable.txt ] && echo "[PASS] Output file exists" || echo "[FAIL] File not found"
[ -s /opt/trivy-vulnerable.txt ] && echo "[PASS] File is not empty" || echo "[FAIL] File is empty"
VEOF

# Generate remaining questions with simpler structure
for q in 19-falco-process-monitor 20-networkpolicy-restricted 21-kubesec-scanning \
         22-runtimeclass-untrusted 23-psp-privileged 24-user-csr-rbac 25-tls-ingress \
         26-cis-benchmark 27-secrets-management 28-process-kill-389 29-role-modification \
         30-projected-sa-token 31-imagepolicy-valhalla 32-cilium-mtls-icmp 33-seccomp-profile \
         34-docker-sock-permissions 35-trivy-delete-vulnerable 36-networkpolicy-egress-deny \
         37-sa-no-secrets 38-falco-monitor-pod 39-audit-node-pvc 40-secrets-retrieve-mount \
         41-dockerfile-deployment-fixes 42-sa-naming-policy 43-psp-restrict-volumes \
         44-sbom-generation 45-role-restriction 46-binary-integrity 47-pod-security-enforce \
         48-docker-sock-securitycontext 49-sa-role-deployments 50-dockerfile-kafka-fixes \
         51-sa-pod-list 52-networkpolicy-port80 53-psp-prevent-privileged \
         54-networkpolicy-deny-ingress-egress 55-exam-strategy; do
  dir="$Q/$q"
  [ -f "$dir/LabSetUp.bash" ] || cat > "$dir/LabSetUp.bash" << 'LEOF'
#!/bin/bash
echo "Lab setup complete. See Questions.bash for task details."
LEOF
  [ -f "$dir/Verify.bash" ] || cat > "$dir/Verify.bash" << 'VEOF'
#!/bin/bash
echo "=== Manual verification required ==="
VEOF
  [ -f "$dir/SolutionNotes.bash" ] || cat > "$dir/SolutionNotes.bash" << 'SEOF'
#!/bin/bash
echo "See raw_test files in 00-cks-labs/ for detailed solutions."
SEOF
done

# Key remaining Questions.bash files

cat > "$Q/19-falco-process-monitor/Questions.bash" << 'QEOF'
# CKS Practice — Falco Process Monitoring
# Domain: Monitoring, Logging and Runtime Security (20%)
#
# Monitor containers for at least 30 seconds using process execution filters.
# Store detected incidents in /opt/node-01/alerts/details
# Format: timestamp,uid/username,processName
QEOF

cat > "$Q/20-networkpolicy-restricted/Questions.bash" << 'QEOF'
# CKS Practice — Restricted NetworkPolicy
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# Create restricted-policy in dev-team namespace allowing ingress to products-service only from:
# - Pods in the same namespace dev-team.
# - Pods with label environment=testing in any namespace.
QEOF

cat > "$Q/21-kubesec-scanning/Questions.bash" << 'QEOF'
# CKS Practice — KubeSec Scanning
# Domain: Supply Chain Security (20%)
#
# Scan kubesec-test.yaml using KubeSec Docker image.
# Apply recommended security changes to achieve score >= 4.
QEOF

cat > "$Q/22-runtimeclass-untrusted/Questions.bash" << 'QEOF'
# CKS Practice — RuntimeClass (untrusted)
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# Create RuntimeClass untrusted with handler runsc.
# Deploy Pod untrusted (alpine:3.18) on node-02.
# Capture dmesg output to /opt/course/7/untrusted-test-dmesg.
QEOF

cat > "$Q/23-psp-privileged/Questions.bash" << 'QEOF'
# CKS Practice — PodSecurityPolicy
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# Create PSP prevent-psp-policy blocking privileged containers.
# Create ClusterRole restrict-access-role, SA psp-restrict-sa in staging.
# Bind with ClusterRoleBinding restrict-access-bind.
QEOF

cat > "$Q/24-user-csr-rbac/Questions.bash" << 'QEOF'
# CKS Practice — User CSR and RBAC
# Domain: Cluster Hardening (15%)
#
# Create user john with CSR. Approve it.
# Create Role john-role in namespace john: list,get,create,delete on pods and secrets.
# Create RoleBinding john-role-binding.
# Verify with kubectl auth can-i.
QEOF

cat > "$Q/25-tls-ingress/Questions.bash" << 'QEOF'
# CKS Practice — TLS Ingress
# Domain: Cluster Setup (15%)
#
# Create TLS Secret from bingo.crt and bingo.key.
# Deploy nginx-pod in testing namespace, expose with Service.
# Create Ingress with TLS (bingo-tls) for host bingo.com.
# Redirect all HTTP traffic to HTTPS.
QEOF

cat > "$Q/26-cis-benchmark/Questions.bash" << 'QEOF'
# CKS Practice — CIS Benchmark Fixes
# Domain: Cluster Setup (15%)
#
# Fix violations:
# API Server: authorization-mode must include Node and RBAC.
# Kubelet: anonymous auth disabled, authorization mode Webhook.
# etcd: --client-cert-auth enabled, --auto-tls disabled.
QEOF

cat > "$Q/27-secrets-management/Questions.bash" << 'QEOF'
# CKS Practice — Secrets Management
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# Retrieve existing secret admin in safe namespace.
# Save username to /home/cert-masters/username.txt, password to password.txt.
# Create secret newsecret (username=dbadmin, password=moresecurepas).
# Create Pod mounting the new secret.
QEOF

cat > "$Q/28-process-kill-389/Questions.bash" << 'QEOF'
# CKS Practice — Process on Port 389
# Domain: System Hardening (10%)
#
# Find the PID of the process on port 389.
# Save all open files to /candidate/13/files.txt.
# Find and delete the executable binary.
QEOF

cat > "$Q/29-role-modification/Questions.bash" << 'QEOF'
# CKS Practice — Role Modification
# Domain: Cluster Hardening (15%)
#
# Modify existing Role bound to sa-dev-1: allow only watch on services.
# Create ClusterRole role-2: allow only update on namespaces.
# Bind with ClusterRoleBinding role-2-binding to sa-dev-1.
QEOF

cat > "$Q/30-projected-sa-token/Questions.bash" << 'QEOF'
# CKS Practice — Projected SA Token
# Domain: Cluster Hardening (15%)
#
# Disable automount on default SA.
# Edit Pod token-demo to mount projected token at /var/run/secrets/tokens/token.jwt.
QEOF

cat > "$Q/31-imagepolicy-valhalla/Questions.bash" << 'QEOF'
# CKS Practice — ImagePolicyWebhook (valhalla)
# Domain: Supply Chain Security (20%)
#
# Configure ImagePolicyWebhook with endpoint https://valhalla.local:8081/image_policy.
# Enforce implicit deny. Config at /etc/kubernetes/imgconfig/.
# Test with /root/16/vulnerable-resource.yaml.
QEOF

cat > "$Q/32-cilium-mtls-icmp/Questions.bash" << 'QEOF'
# CKS Practice — CiliumNetworkPolicy
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# In namespace team-dev, create two CiliumNetworkPolicies:
# team-dev: Deny outgoing ICMP from Deployment stuff to Service backend.
# team-dev-2: Enable Mutual Authentication from role=database to role=api-service.
QEOF

cat > "$Q/33-seccomp-profile/Questions.bash" << 'QEOF'
# CKS Practice — Seccomp Profile
# Domain: System Hardening (10%)
#
# Create custom Seccomp profile allowing only read, write, exit, sigreturn.
# Apply to Deployment webapp in secure-app namespace.
QEOF

cat > "$Q/34-docker-sock-permissions/Questions.bash" << 'QEOF'
# CKS Practice — Docker Socket Permissions
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# A Pod in ci-cd namespace mounts /var/run/docker.sock.
# Change ownership and permissions to restrict access.
# Verify the container cannot run arbitrary containers.
QEOF

cat > "$Q/35-trivy-delete-vulnerable/Questions.bash" << 'QEOF'
# CKS Practice — Trivy: Scan and Delete
# Domain: Supply Chain Security (20%)
#
# Scan images used by Pods in nato namespace for HIGH/CRITICAL vulns.
# Delete any Pods running vulnerable images.
QEOF

cat > "$Q/36-networkpolicy-egress-deny/Questions.bash" << 'QEOF'
# CKS Practice — Default Deny Egress
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# Create default-deny in testing namespace blocking all Egress traffic.
# Optionally allow DNS egress.
QEOF

cat > "$Q/37-sa-no-secrets/Questions.bash" << 'QEOF'
# CKS Practice — SA Without Secret Access
# Domain: Cluster Hardening (15%)
#
# Create backend-qa SA in qa namespace that cannot access any secrets.
# Update existing frontend Pod to use this SA.
QEOF

cat > "$Q/38-falco-monitor-pod/Questions.bash" << 'QEOF'
# CKS Practice — Falco: Monitor Single Pod
# Domain: Monitoring, Logging and Runtime Security (20%)
#
# Monitor Pod tomcat for anomalous process activity for 40+ seconds.
# Store incidents in /home/anomalous/report as [timestamp],[uid],[processName].
QEOF

cat > "$Q/39-audit-node-pvc/Questions.bash" << 'QEOF'
# CKS Practice — Audit: Node and PVC Changes
# Domain: Monitoring, Logging and Runtime Security (20%)
#
# Logs at /var/log/kubernetes-logs.log, retain 5 days, 10 backups.
# Log Node changes at RequestResponse.
# Log PVC changes in frontend namespace at Request level.
QEOF

cat > "$Q/40-secrets-retrieve-mount/Questions.bash" << 'QEOF'
# CKS Practice — Secrets: Retrieve and Mount
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# Retrieve CA cert from existing secret in dev namespace, save to ca.crt.
# Create secret app-config-secret (APP_USER=appadmin, APP_PASS=Sup3rS3cret).
# Deploy Pod app-pod mounting the secret at /etc/app-config.
QEOF

cat > "$Q/41-dockerfile-deployment-fixes/Questions.bash" << 'QEOF'
# CKS Practice — Dockerfile and Deployment Fixes (Couchbase)
# Domain: System Hardening (10%)
#
# Fix two issues in the Dockerfile and two in the Deployment manifest.
# Files at /home/candidate/10/. Use nobody UID 65535.
QEOF

cat > "$Q/42-sa-naming-policy/Questions.bash" << 'QEOF'
# CKS Practice — SA Naming Policy
# Domain: Cluster Hardening (15%)
#
# Create frontend-sa in qa namespace (automountServiceAccountToken: false).
# Update Pod manifest to use it. Clean up unused SAs.
QEOF

cat > "$Q/43-psp-restrict-volumes/Questions.bash" << 'QEOF'
# CKS Practice — PSP: Restrict Volumes
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# Create PSP prevent-volume-policy allowing only PVC volumes.
# Create SA psp-sa in restricted, ClusterRole psp-role, bind with psp-role-binding.
# Test with a Pod using a Secret volume (should fail).
QEOF

cat > "$Q/44-sbom-generation/Questions.bash" << 'QEOF'
# CKS Practice — SBOM Generation
# Domain: Supply Chain Security (20%)
#
# Generate SPDX-JSON SBOM for kube-apiserver:v1.32.0 -> /opt/candidate/13/sbom1.json
# Generate CycloneDX SBOM for kube-controller-manager:v1.32.0 -> sbom2.json
# Scan existing SBOM at sbom_check.json -> sbom_result.json
QEOF

cat > "$Q/45-role-restriction/Questions.bash" << 'QEOF'
# CKS Practice — Role Restriction
# Domain: Cluster Hardening (15%)
#
# Edit Role bound to test-sa: only allow get on Pods.
# Create test-role-2: only update on StatefulSets.
# Bind with test-role-2-bind to test-sa.
QEOF

cat > "$Q/46-binary-integrity/Questions.bash" << 'QEOF'
# CKS Practice — Binary Integrity
# Domain: Cluster Hardening (15%)
#
# Validate sha512 checksums of 4 K8s binaries at /opt/candidate/15/binaries.
# Delete any that don't match the provided hashes.
QEOF

cat > "$Q/47-pod-security-enforce/Questions.bash" << 'QEOF'
# CKS Practice — Pod Security: Enforce Restricted
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# Label team-blue namespace with restricted Pod Security enforcement.
# Delete Pod from Deployment privileged-runner.
# Capture ReplicaSet failure events to /opt/candidate/16/logs.
QEOF

cat > "$Q/48-docker-sock-securitycontext/Questions.bash" << 'QEOF'
# CKS Practice — Docker Socket: SecurityContext
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# Deployment docker-admin in sandbox mounts docker.sock.
# Reduce risk: don't run as root, drop capabilities, read-only filesystem.
QEOF

cat > "$Q/49-sa-role-deployments/Questions.bash" << 'QEOF'
# CKS Practice — SA Role for Deployments
# Domain: Cluster Hardening (15%)
#
# Fetch SA name from nginx-pod in test-system, save to /candidate/sa-name.txt.
# Create Role for list/get/watch Deployments, bind to the SA.
QEOF

cat > "$Q/50-dockerfile-kafka-fixes/Questions.bash" << 'QEOF'
# CKS Practice — Dockerfile and Deployment Fixes (Kafka)
# Domain: System Hardening (10%)
#
# Fix two issues in the Dockerfile and two in the Deployment at /home/manifests.
# Use nobody UID 65535.
QEOF

cat > "$Q/51-sa-pod-list/Questions.bash" << 'QEOF'
# CKS Practice — SA with Pod List Permission
# Domain: Cluster Hardening (15%)
#
# Create backend-sa SA, Role pod-reader (list/get pods), bind to SA.
# Deploy Pod backend-pod using the SA and verify it can list Pods.
QEOF

cat > "$Q/52-networkpolicy-port80/Questions.bash" << 'QEOF'
# CKS Practice — NetworkPolicy: Allow Port 80
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# Create allow-np in staging namespace.
# Allow ingress from same namespace on port 80 only.
# Deny traffic from outside staging.
QEOF

cat > "$Q/53-psp-prevent-privileged/Questions.bash" << 'QEOF'
# CKS Practice — PSP: Prevent Privileged
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# Create PSP prevent-privileged-policy.
# Create SA psp-sa in default, ClusterRole prevent-role, bind with prevent-role-binding.
# Test by creating a privileged pod (should fail).
QEOF

cat > "$Q/54-networkpolicy-deny-ingress-egress/Questions.bash" << 'QEOF'
# CKS Practice — Default Deny All Traffic
# Domain: Minimize Microservice Vulnerabilities (20%)
#
# Create deny-network in test namespace.
# Block all ingress and egress traffic for every pod.
# Skeleton at /home/policy/network-policy.yaml.
QEOF

cat > "$Q/55-exam-strategy/Questions.bash" << 'QEOF'
# CKS Exam Strategy Tips
#
# TIME MANAGEMENT:
# - If a task takes > 5 minutes thinking, skip it.
# - Collect easy points first.
# - Use aliases, save YAMLs.
#
# EXPECT DELAYS:
# - Network latency in the terminal.
# - Proctor interruptions. Stay calm, breathe, jump back in.
#
# CONCEPTS OVER MEMORIZATION:
# - Understand the WHY behind each fix.
# - PSP is deprecated (K8s 1.25+) but attributes match securityContext/PSS.
# - If you understand the security issue, you can fix it regardless of phrasing.
#
# CKS DOMAIN WEIGHTS:
# - Cluster Setup: 15%
# - Cluster Hardening: 15%
# - System Hardening: 10%
# - Minimize Microservice Vulnerabilities: 20%
# - Supply Chain Security: 20%
# - Monitoring, Logging and Runtime Security: 20%
#
# PRACTICE OPTIONS:
# - KillerCoda, iximiuz Labs, KodeKloud for ready-to-use playgrounds.
# - Terraform for custom AWS/EKS clusters.
# - Mental simulation: analyze, formulate, verify against solutions.
QEOF

echo ""
echo "=== All 55 questions generated ==="
echo ""
ls -1 "$Q" | wc -l
echo "question directories created."
