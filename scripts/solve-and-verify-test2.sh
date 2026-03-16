#!/bin/bash
# CKS-PREP-2025 — Solve all Test 2 questions (Q17-Q32) and verify
#
# This script:
#   1. Runs all LabSetUp scripts (sets up the broken state)
#   2. Applies the correct solution for each question
#   3. Runs all Verify scripts (checks solutions are correct)
#
# Usage:
#   bash scripts/solve-and-verify-test2.sh
#
# Prerequisites: run scripts/setup-tools.sh first (installs Trivy, Falco, etc.)

set -uo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
Q="$REPO_DIR/questions"
MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0
ERROR_COUNT=0
declare -a RESULTS

wait_for_apiserver() {
  echo "  Waiting for API server to restart..."
  sleep 10
  local i=0
  while ! kubectl get nodes &>/dev/null 2>&1; do
    sleep 3
    ((i++))
    if [ $i -gt 40 ]; then
      echo -e "  ${RED}API server did not recover after 120s${NC}"
      return 1
    fi
  done
  kubectl wait --for=condition=Ready pod -l component=kube-apiserver \
    -n kube-system --timeout=60s &>/dev/null 2>&1 || true
  sleep 3
  echo "  API server is back."
}

add_apiserver_volume() {
  local mount_path="$1"
  local vol_name="$2"
  local read_only="$3"
  local host_path="$4"
  local host_type="$5"

  if grep -q "name: ${vol_name}" "$MANIFEST"; then
    return 0
  fi

  sed -i "/    volumeMounts:/a\\    - mountPath: ${mount_path}\n      name: ${vol_name}\n      readOnly: ${read_only}" "$MANIFEST"
  sed -i "/^  volumes:/a\\  - hostPath:\n      path: ${host_path}\n      type: ${host_type}\n    name: ${vol_name}" "$MANIFEST"
}

run_verify() {
  local qnum="$1"
  local qdir="$2"
  echo -n "  Verifying... "
  OUTPUT=$(bash "$Q/$qdir/Verify.bash" 2>&1)
  if echo "$OUTPUT" | grep -q "ALL CHECKS PASSED\|RESULT: PASS"; then
    echo -e "${GREEN}PASS${NC}"
    RESULTS+=("Q${qnum}: PASS")
    ((PASS_COUNT++))
  else
    echo -e "${RED}FAIL${NC}"
    echo "$OUTPUT" | grep -E '\[FAIL\]|✗' | sed 's/^/    /'
    RESULTS+=("Q${qnum}: FAIL")
    ((FAIL_COUNT++))
  fi
}

echo -e "${CYAN}=== CKS-PREP-2025 Solve & Verify — Test 2 (Q17-Q32) ===${NC}"
echo ""

# =====================================================================
# PHASE 1: Run all LabSetUp scripts
# =====================================================================
echo -e "${CYAN}--- Phase 1: Setting up all labs ---${NC}"

# Non-API-server labs first
for qdir in \
  18-trivy-scanning \
  19-falco-process-monitor \
  20-networkpolicy-restricted \
  21-kubesec-scanning \
  22-runtimeclass-untrusted \
  23-psp-privileged \
  24-user-csr-rbac \
  25-tls-ingress \
  27-secrets-management \
  28-process-kill-389 \
  29-role-modification \
  30-projected-sa-token \
  31-imagepolicy-valhalla \
  32-cilium-mtls-icmp; do
  NUM=$(echo "$qdir" | grep -oE '^[0-9]+')
  echo -n "Setting up Q$NUM... "
  if bash "$Q/$qdir/LabSetUp.bash" &>/dev/null; then
    echo -e "${GREEN}done${NC}"
  else
    echo -e "${RED}FAILED${NC}"
  fi
done

# Q17 (audit logging — only creates files, no API server change in setup)
echo -n "Setting up Q17... "
if bash "$Q/17-audit-logging-extended/LabSetUp.bash" &>/dev/null; then
  echo -e "${GREEN}done${NC}"
else
  echo -e "${RED}FAILED${NC}"
fi

# Q26 (CIS benchmark — modifies API server + kubelet + etcd) — LAST
echo -n "Setting up Q26 (modifies API server + kubelet + etcd)... "
if bash "$Q/26-cis-benchmark/LabSetUp.bash" &>/dev/null; then
  echo -e "${GREEN}done${NC}"
else
  echo -e "${RED}FAILED${NC}"
fi

wait_for_apiserver

echo ""
echo -e "${CYAN}--- Phase 2: Solving all questions ---${NC}"
echo ""

# =====================================================================
# Q17 — Audit Logging Extended
# =====================================================================
echo -e "${CYAN}Q17: Audit Logging Extended${NC}"

cat > /etc/audit/audit-policy.yaml << 'YAML'
apiVersion: audit.k8s.io/v1
kind: Policy
omitStages:
  - "RequestReceived"
rules:
  - level: RequestResponse
    resources:
      - group: ""
        resources: ["namespaces"]
  - level: Request
    namespaces: ["kube-system"]
    resources:
      - group: ""
        resources: ["secrets"]
  - level: Request
    resources:
      - group: ""
      - group: "extensions"
  - level: Metadata
    resources:
      - group: ""
        resources: ["pods/portforward", "services/proxy"]
  - level: Metadata
YAML

if ! grep -q 'audit-log-path' "$MANIFEST"; then
  sed -i '/--authorization-mode/a\    - --audit-policy-file=/etc/audit/audit-policy.yaml\n    - --audit-log-path=/var/log/kubernetes-logs.log\n    - --audit-log-maxage=12\n    - --audit-log-maxbackup=8\n    - --audit-log-maxsize=200' "$MANIFEST"
fi

add_apiserver_volume "/etc/audit/audit-policy.yaml" "audit" "true" "/etc/audit/audit-policy.yaml" "File"
add_apiserver_volume "/var/log" "audit-log" "false" "/var/log" "DirectoryOrCreate"

wait_for_apiserver
run_verify "17" "17-audit-logging-extended"
echo ""

# =====================================================================
# Q18 — Trivy Scanning
# =====================================================================
echo -e "${CYAN}Q18: Trivy Image Scanning${NC}"
echo "  Scanning 5 images (this may take a few minutes)..."
trivy image --severity HIGH,CRITICAL --output /opt/trivy-vulnerable.txt ubuntu:18.04 2>/dev/null || true
trivy image --severity HIGH,CRITICAL registry.k8s.io/kube-apiserver:v1.24.0 >> /opt/trivy-vulnerable.txt 2>/dev/null || true
trivy image --severity HIGH,CRITICAL registry.k8s.io/kube-scheduler:v1.23.0 >> /opt/trivy-vulnerable.txt 2>/dev/null || true
trivy image --severity HIGH,CRITICAL postgres:12 >> /opt/trivy-vulnerable.txt 2>/dev/null || true
trivy image --severity HIGH,CRITICAL httpd:2.4.49 >> /opt/trivy-vulnerable.txt 2>/dev/null || true
run_verify "18" "18-trivy-scanning"
echo ""

# =====================================================================
# Q19 — Falco Process Monitor
# =====================================================================
echo -e "${CYAN}Q19: Falco Process Monitoring${NC}"

cat > /home/candidate/falco-rule.yaml << 'YAML'
- rule: Container Drift Detected
  desc: New executable created in a container
  condition: >
    evt.type in (open,openat,creat) and evt.is_open_exec=true and container
    and not runc_writing_exec_fifo
    and not runc_var_lib_docker and not user_known_container_drift_activities
    and evt.rawres>=0
  output:
    %evt.time,%user.uid,%proc.name
  priority: ERROR
  tags: [security]
YAML

# Configure Falco file output (if falco is installed)
if [ -f /etc/falco/falco.yaml ]; then
  sed -i '/^file_output:/,/^[a-z]/{
    s/enabled: false/enabled: true/
    s|filename:.*|filename: /opt/falco-alerts/details|
  }' /etc/falco/falco.yaml
fi

run_verify "19" "19-falco-process-monitor"
echo ""

# =====================================================================
# Q20 — NetworkPolicy Restricted
# =====================================================================
echo -e "${CYAN}Q20: NetworkPolicy Restricted${NC}"
kubectl apply -f - <<'EOF' 2>/dev/null
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: restricted-policy
  namespace: dev-team
spec:
  podSelector:
    matchLabels:
      environment: dev
  policyTypes:
  - Ingress
  ingress:
    - from:
        - podSelector: {}
    - from:
        - namespaceSelector: {}
          podSelector:
            matchLabels:
              environment: testing
EOF
run_verify "20" "20-networkpolicy-restricted"
echo ""

# =====================================================================
# Q21 — KubeSec Scanning
# =====================================================================
echo -e "${CYAN}Q21: KubeSec Scanning${NC}"
cat > /home/candidate/kubesec-test.yaml << 'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: kubesec-demo
spec:
  containers:
    - name: kubesec-demo
      image: gcr.io/google-samples/node-hello:1.0
      securityContext:
        runAsUser: 1000
        runAsNonRoot: true
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop:
            - ALL
YAML
run_verify "21" "21-kubesec-scanning"
echo ""

# =====================================================================
# Q22 — RuntimeClass untrusted
# =====================================================================
echo -e "${CYAN}Q22: RuntimeClass untrusted${NC}"
WORKER=$(kubectl get nodes --no-headers | grep -v control-plane | awk '{print $1}' | head -1)
# If no worker, use controlplane
[ -z "$WORKER" ] && WORKER=$(kubectl get nodes --no-headers | awk '{print $1}' | head -1)

kubectl apply -f - <<EOF 2>/dev/null
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: untrusted
handler: runsc
EOF

kubectl delete pod untrusted --ignore-not-found --grace-period=0 --force &>/dev/null || true
sleep 2

kubectl apply -f - <<EOF 2>/dev/null
apiVersion: v1
kind: Pod
metadata:
  name: untrusted
spec:
  nodeName: $WORKER
  runtimeClassName: untrusted
  containers:
  - name: untrusted
    image: alpine:3.18
    command: ["/bin/sh", "-c", "sleep 3600"]
EOF

# Create dmesg file (pod may be Pending without gVisor)
kubectl exec untrusted -- dmesg > /opt/course/untrusted-test-dmesg 2>/dev/null || \
  echo "Pod pending — gVisor not installed" > /opt/course/untrusted-test-dmesg

run_verify "22" "22-runtimeclass-untrusted"
echo ""

# =====================================================================
# Q23 — PSP Privileged (manifest-only)
# =====================================================================
echo -e "${CYAN}Q23: PodSecurityPolicy (manifest-only)${NC}"
cat > /home/candidate/23/psp-solution.yaml << 'YAML'
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: prevent-psp-policy
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities: ["ALL"]
  volumes:
    - configMap
    - emptyDir
    - projected
    - secret
    - downwardAPI
    - persistentVolumeClaim
  runAsUser:
    rule: MustRunAsNonRoot
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  fsGroup:
    rule: RunAsAny
  readOnlyRootFilesystem: true
---
# Commands to run (PSP API removed in K8s 1.25+):
# kubectl create clusterrole restrict-access-role --verb=use --resource=podsecuritypolicies.policy --resource-name=prevent-psp-policy
# kubectl create serviceaccount psp-restrict-sa -n staging
# kubectl create clusterrolebinding restrict-access-bind --clusterrole=restrict-access-role --serviceaccount=staging:psp-restrict-sa
YAML
run_verify "23" "23-psp-privileged"
echo ""

# =====================================================================
# Q24 — User CSR RBAC
# =====================================================================
echo -e "${CYAN}Q24: User CSR and RBAC${NC}"

CSR_B64=$(cat /home/candidate/john.csr | base64 | tr -d "\n")

kubectl apply -f - <<EOF 2>/dev/null
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: john-csr
spec:
  request: $CSR_B64
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400
  usages:
  - client auth
EOF

kubectl certificate approve john-csr 2>/dev/null
kubectl get csr john-csr -o jsonpath='{.status.certificate}' | base64 -d > /home/candidate/john.crt 2>/dev/null || true

kubectl create role john-role --verb=list,get,create,delete --resource=pods,secrets -n john --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null
kubectl create rolebinding john-role-binding --role=john-role --user=john -n john --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null

run_verify "24" "24-user-csr-rbac"
echo ""

# =====================================================================
# Q25 — TLS Ingress
# =====================================================================
echo -e "${CYAN}Q25: TLS Ingress${NC}"

kubectl create secret tls bingo-tls \
  --cert=/home/candidate/bingo.crt \
  --key=/home/candidate/bingo.key \
  -n testing --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null

kubectl run nginx-pod -n testing --image=nginx --port=80 2>/dev/null || true
kubectl expose pod nginx-pod -n testing --port=80 --target-port=80 2>/dev/null || true

kubectl apply -f - <<'EOF' 2>/dev/null
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: bingo-com
  namespace: testing
  annotations:
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  rules:
  - host: bingo.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-pod
            port:
              number: 80
  tls:
  - hosts:
    - bingo.com
    secretName: bingo-tls
EOF

run_verify "25" "25-tls-ingress"
echo ""

# =====================================================================
# Q26 — CIS Benchmark Fixes
# =====================================================================
echo -e "${CYAN}Q26: CIS Benchmark Fixes${NC}"
KUBELET_CONFIG="/var/lib/kubelet/config.yaml"
ETCD_MANIFEST="/etc/kubernetes/manifests/etcd.yaml"

# Fix API server: add Node to authorization-mode
sed -i 's/--authorization-mode=RBAC/--authorization-mode=Node,RBAC/' "$MANIFEST"

# Fix kubelet
sed -i '/anonymous:/,/enabled:/{s/enabled: true/enabled: false/}' "$KUBELET_CONFIG"
sed -i '/authorization:/,/mode:/{s/mode: AlwaysAllow/mode: Webhook/}' "$KUBELET_CONFIG"
systemctl daemon-reload
systemctl restart kubelet

# Fix etcd
sed -i '/--auto-tls=true/d' "$ETCD_MANIFEST"
if ! grep -q '\-\-client-cert-auth=true' "$ETCD_MANIFEST"; then
  sed -i '/- --trusted-ca-file/a\    - --client-cert-auth=true' "$ETCD_MANIFEST"
fi

wait_for_apiserver
run_verify "26" "26-cis-benchmark"
echo ""

# =====================================================================
# Q27 — Secrets Management
# =====================================================================
echo -e "${CYAN}Q27: Secrets Management${NC}"

kubectl get secret admin -n safe -o jsonpath='{.data.username}' | base64 -d > /home/cert-masters/username.txt
kubectl get secret admin -n safe -o jsonpath='{.data.password}' | base64 -d > /home/cert-masters/password.txt

kubectl create secret generic newsecret \
  --from-literal=username=dbadmin \
  --from-literal=password=moresecurepas \
  -n safe --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null

kubectl delete pod mysecret-pod -n safe --ignore-not-found --grace-period=0 --force &>/dev/null || true
sleep 2

kubectl apply -f - <<'EOF' 2>/dev/null
apiVersion: v1
kind: Pod
metadata:
  name: mysecret-pod
  namespace: safe
spec:
  containers:
  - name: db-container
    image: redis
    volumeMounts:
    - name: secret-vol
      mountPath: /etc/mysecret
      readOnly: true
  volumes:
  - name: secret-vol
    secret:
      secretName: newsecret
EOF
kubectl wait --for=condition=Ready pod/mysecret-pod -n safe --timeout=60s &>/dev/null || true

run_verify "27" "27-secrets-management"
echo ""

# =====================================================================
# Q28 — Process Kill 389
# =====================================================================
echo -e "${CYAN}Q28: Process Kill 389${NC}"

# Find PID on port 389
PID=""
if command -v ss &>/dev/null; then
  PID=$(ss -tlnp 'sport = :389' 2>/dev/null | grep -oP 'pid=\K[0-9]+' | head -1)
fi
if [ -z "$PID" ] && command -v netstat &>/dev/null; then
  PID=$(netstat -tlnp 2>/dev/null | grep ':389 ' | awk '{print $7}' | cut -d/ -f1 | head -1)
fi

if [ -n "$PID" ]; then
  # Save open file descriptors
  ls -l /proc/$PID/fd > /candidate/13/files.txt 2>/dev/null || echo "no fd" > /candidate/13/files.txt

  # Find and delete binary
  BINARY=$(readlink -f /proc/$PID/exe 2>/dev/null)
  kill -9 $PID 2>/dev/null || true

  if [ -n "$BINARY" ]; then
    rm -f "$BINARY"
  fi
  # Also remove fake-ldap if it exists
  rm -f /usr/local/bin/fake-ldap
else
  echo "  No process on port 389 (may already be killed)"
  echo "no process found" > /candidate/13/files.txt
fi

run_verify "28" "28-process-kill-389"
echo ""

# =====================================================================
# Q29 — Role Modification
# =====================================================================
echo -e "${CYAN}Q29: Role Modification${NC}"

# Restrict Role role-1 to watch on services only
kubectl apply -f - <<'EOF' 2>/dev/null
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: role-1
  namespace: security
rules:
- apiGroups: [""]
  resources: ["services"]
  verbs: ["watch"]
EOF

kubectl create clusterrole role-2 --verb=update --resource=namespaces \
  --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null
kubectl create clusterrolebinding role-2-binding \
  --clusterrole=role-2 --serviceaccount=security:sa-dev-1 \
  --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null

run_verify "29" "29-role-modification"
echo ""

# =====================================================================
# Q30 — Projected SA Token
# =====================================================================
echo -e "${CYAN}Q30: Projected SA Token${NC}"

kubectl patch sa default -p '{"automountServiceAccountToken": false}' 2>/dev/null

kubectl delete pod token-demo --ignore-not-found --grace-period=0 --force &>/dev/null || true
sleep 2

kubectl apply -f - <<'EOF' 2>/dev/null
apiVersion: v1
kind: Pod
metadata:
  name: token-demo
  namespace: default
spec:
  serviceAccountName: default
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: token-vol
      mountPath: /var/run/secrets/tokens
      readOnly: true
  volumes:
  - name: token-vol
    projected:
      sources:
      - serviceAccountToken:
          path: token.jwt
          expirationSeconds: 600
          audience: https://kubernetes.default.svc.cluster.local
EOF
kubectl wait --for=condition=Ready pod/token-demo --timeout=60s &>/dev/null || true

run_verify "30" "30-projected-sa-token"
echo ""

# =====================================================================
# Q31 — ImagePolicyWebhook valhalla (file-based + rollback)
# =====================================================================
echo -e "${CYAN}Q31: ImagePolicyWebhook (valhalla)${NC}"

# Fix defaultAllow
sed -i 's/defaultAllow: true/defaultAllow: false/' /etc/kubernetes/imgconfig/admission_configuration.yaml

# Add ImagePolicyWebhook to admission plugins
if ! grep 'enable-admission-plugins' "$MANIFEST" | grep -q 'ImagePolicyWebhook'; then
  sed -i 's/--enable-admission-plugins=\(.*\)/--enable-admission-plugins=\1,ImagePolicyWebhook/' "$MANIFEST"
fi

# Add admission-control-config-file flag
if ! grep -q 'admission-control-config-file=/etc/kubernetes/imgconfig' "$MANIFEST"; then
  sed -i '/--enable-admission-plugins/a\    - --admission-control-config-file=/etc/kubernetes/imgconfig/admission_configuration.yaml' "$MANIFEST"
fi

# Add volume mount
add_apiserver_volume "/etc/kubernetes/imgconfig" "imgconfig" "true" "/etc/kubernetes/imgconfig" "DirectoryOrCreate"

wait_for_apiserver
run_verify "31" "31-imagepolicy-valhalla"

# Roll back Q31 API server manifest changes — no webhook backend on KillerCoda
echo "  Rolling back Q31 API server changes (no webhook backend)..."
sed -i 's/,ImagePolicyWebhook//' "$MANIFEST"
sed -i '/--admission-control-config-file=\/etc\/kubernetes\/imgconfig/d' "$MANIFEST"
wait_for_apiserver
echo ""

# =====================================================================
# Q32 — Cilium mTLS + ICMP
# =====================================================================
echo -e "${CYAN}Q32: CiliumNetworkPolicy mTLS + ICMP${NC}"

kubectl apply -f - <<'EOF' 2>/dev/null
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: team-dev
  namespace: team-dev
spec:
  endpointSelector:
    matchLabels:
      role: stuff
  egressDeny:
    - icmps:
        - fields:
            - type: 8
              family: IPv4
      toEndpoints:
        - matchLabels:
            role: backend
EOF

kubectl apply -f - <<'EOF' 2>/dev/null
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: team-dev-2
  namespace: team-dev
spec:
  endpointSelector:
    matchLabels:
      role: database
  ingress:
    - fromEndpoints:
        - matchLabels:
            role: api-service
      authentication:
        mode: "required"
EOF

run_verify "32" "32-cilium-mtls-icmp"
echo ""

# =====================================================================
# SUMMARY
# =====================================================================
echo -e "${CYAN}=== FINAL SUMMARY ===${NC}"
echo ""
for r in "${RESULTS[@]}"; do
  if echo "$r" | grep -q "PASS"; then
    echo -e "  ${GREEN}$r${NC}"
  else
    echo -e "  ${RED}$r${NC}"
  fi
done
echo ""
echo -e "Total: ${GREEN}$PASS_COUNT pass${NC}, ${RED}$FAIL_COUNT fail${NC}, ${RED}$ERROR_COUNT error${NC}"
echo ""
if [ $FAIL_COUNT -eq 0 ] && [ $ERROR_COUNT -eq 0 ]; then
  echo -e "${GREEN}All 16 questions verified successfully!${NC}"
else
  echo -e "${YELLOW}Some questions need attention.${NC}"
fi
