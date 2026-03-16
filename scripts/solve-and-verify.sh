#!/bin/bash
# CKS-PREP-2025 — Solve all Test 1 questions and verify
#
# This script:
#   1. Runs all LabSetUp scripts (sets up the broken state)
#   2. Applies the correct solution for each question
#   3. Runs all Verify scripts (checks solutions are correct)
#
# Usage:
#   bash scripts/solve-and-verify.sh
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
  # Give kubelet time to detect the manifest change and start the restart
  sleep 8
  # Wait for the API server to respond
  local i=0
  while ! kubectl get nodes &>/dev/null 2>&1; do
    sleep 2
    ((i++))
    if [ $i -gt 60 ]; then
      echo -e "  ${RED}API server did not recover after 120s${NC}"
      return 1
    fi
  done
  # Let the pod fully stabilize before continuing
  sleep 5
  echo "  API server is back."
}

# Add a volumeMount + volume to the kube-apiserver static pod manifest
# using sed (NOT yaml.dump, which corrupts the file).
# Args: mount_path vol_name read_only host_path host_type
add_apiserver_volume() {
  local mount_path="$1"
  local vol_name="$2"
  local read_only="$3"
  local host_path="$4"
  local host_type="$5"

  # Skip if already present
  if grep -q "name: ${vol_name}" "$MANIFEST"; then
    return 0
  fi

  # Insert volumeMount after the "    volumeMounts:" line
  sed -i "/    volumeMounts:/a\\    - mountPath: ${mount_path}\n      name: ${vol_name}\n      readOnly: ${read_only}" "$MANIFEST"

  # Insert volume after the "  volumes:" line
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

echo -e "${CYAN}=== CKS-PREP-2025 Solve & Verify ===${NC}"
echo ""

# =====================================================================
# PHASE 1: Run all LabSetUp scripts
# =====================================================================
echo -e "${CYAN}--- Phase 1: Setting up all labs ---${NC}"

# Non-API-server labs first (safe to run in any order)
for qdir in \
  02-networkpolicy-deny-all \
  03-serviceaccount-token \
  06-dockerfile-pod-fixes \
  09-stateless-immutable-pods \
  10-runtimeclass-gvisor \
  12-docker-sock-removal \
  13-istio-mtls \
  14-pod-security-admission \
  15-worker-node-upgrade \
  16-falco-devmem; do
  NUM=$(echo "$qdir" | grep -oE '^[0-9]+')
  echo -n "Setting up Q$NUM... "
  if bash "$Q/$qdir/LabSetUp.bash" &>/dev/null; then
    echo -e "${GREEN}done${NC}"
  else
    echo -e "${RED}FAILED${NC}"
  fi
done

# Q01 (AppArmor — SSH to worker, no API server change)
echo -n "Setting up Q01... "
if bash "$Q/01-apparmor-profile/LabSetUp.bash" &>/dev/null; then
  echo -e "${GREEN}done${NC}"
else
  echo -e "${RED}FAILED${NC}"
fi

# Q05 (audit logging — only creates files, doesn't touch API server manifest)
echo -n "Setting up Q05... "
if bash "$Q/05-audit-logging/LabSetUp.bash" &>/dev/null; then
  echo -e "${GREEN}done${NC}"
else
  echo -e "${RED}FAILED${NC}"
fi

# Q08 (encryption — only creates /etc/kubernetes/enc dir)
echo -n "Setting up Q08... "
if bash "$Q/08-encryption-at-rest/LabSetUp.bash" &>/dev/null; then
  echo -e "${GREEN}done${NC}"
else
  echo -e "${RED}FAILED${NC}"
fi

# Q11 (ImagePolicyWebhook — creates config files only)
echo -n "Setting up Q11... "
if bash "$Q/11-imagepolicy-webhook/LabSetUp.bash" &>/dev/null; then
  echo -e "${GREEN}done${NC}"
else
  echo -e "${RED}FAILED${NC}"
fi

# API-server-modifying setups last
echo -n "Setting up Q04 (modifies API server)... "
if bash "$Q/04-secure-api-server/LabSetUp.bash" &>/dev/null; then
  echo -e "${GREEN}done${NC}"
else
  echo -e "${RED}FAILED${NC}"
fi

echo -n "Setting up Q07 (modifies API server + kubelet + etcd)... "
if bash "$Q/07-kube-bench/LabSetUp.bash" &>/dev/null; then
  echo -e "${GREEN}done${NC}"
else
  echo -e "${RED}FAILED${NC}"
fi

wait_for_apiserver

echo ""
echo -e "${CYAN}--- Phase 2: Solving all questions ---${NC}"
echo ""

# =====================================================================
# Q01 — AppArmor
# =====================================================================
echo -e "${CYAN}Q01: AppArmor Profile${NC}"
WORKER=$(kubectl get nodes --no-headers | grep -v control-plane | awk '{print $1}' | head -1)
echo "  Loading AppArmor profile on $WORKER..."
ssh "$WORKER" 'apparmor_parser -r -q /etc/apparmor.d/nginx_apparmor' 2>/dev/null

echo "  Creating pod with AppArmor profile..."
cat > /tmp/q01-pod.yaml << YAML
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  nodeName: $WORKER
  containers:
  - name: nginx-pod
    image: nginx:1.19.0
    ports:
    - containerPort: 80
    securityContext:
      appArmorProfile:
        type: Localhost
        localhostProfile: nginx-profile-2
YAML
kubectl delete pod nginx-pod --ignore-not-found --grace-period=0 --force &>/dev/null || true
sleep 2
kubectl apply -f /tmp/q01-pod.yaml &>/dev/null
kubectl wait --for=condition=Ready pod/nginx-pod --timeout=60s &>/dev/null || true
run_verify "01" "01-apparmor-profile"
echo ""

# =====================================================================
# Q02 — NetworkPolicy deny-all
# =====================================================================
echo -e "${CYAN}Q02: NetworkPolicy deny-all${NC}"
kubectl apply -f - <<'EOF' 2>/dev/null
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: testing
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF
run_verify "02" "02-networkpolicy-deny-all"
echo ""

# =====================================================================
# Q03 — ServiceAccount Token
# =====================================================================
echo -e "${CYAN}Q03: ServiceAccount Token Management${NC}"
kubectl patch sa default -n default -p '{"automountServiceAccountToken": false}' &>/dev/null

kubectl apply -f - <<'EOF' 2>/dev/null
apiVersion: v1
kind: Secret
metadata:
  name: default-sa-token
  annotations:
    kubernetes.io/service-account.name: "default"
type: kubernetes.io/service-account-token
EOF

kubectl delete pod nginx-pod --ignore-not-found --grace-period=0 --force &>/dev/null || true
sleep 2
kubectl apply -f - <<'EOF' 2>/dev/null
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  serviceAccountName: default
  automountServiceAccountToken: false
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: token-vol
      mountPath: /var/run/secrets/kubernetes.io/serviceaccount/
      readOnly: true
  volumes:
  - name: token-vol
    secret:
      secretName: default-sa-token
EOF
kubectl wait --for=condition=Ready pod/nginx-pod --timeout=60s &>/dev/null || true
run_verify "03" "03-serviceaccount-token"
echo ""

# =====================================================================
# Q04 — Re-secure API Server
# =====================================================================
echo -e "${CYAN}Q04: Re-secure API Server${NC}"

# Fix authorization mode
sed -i 's/--authorization-mode=AlwaysAllow/--authorization-mode=Node,RBAC/' "$MANIFEST"
# Add --anonymous-auth=false
if ! grep -q '\-\-anonymous-auth' "$MANIFEST"; then
  sed -i '/--authorization-mode/a\    - --anonymous-auth=false' "$MANIFEST"
fi
# Fix admission plugins: AlwaysAdmit -> NodeRestriction
sed -i 's/AlwaysAdmit/NodeRestriction/' "$MANIFEST"

wait_for_apiserver

# Delete anonymous CRB (must be AFTER API server is back)
kubectl delete clusterrolebinding system:anonymous &>/dev/null || true
run_verify "04" "04-secure-api-server"
echo ""

# =====================================================================
# Q05 — Audit Logging
# =====================================================================
echo -e "${CYAN}Q05: Audit Logging${NC}"

# Write the full audit policy
cat > /etc/audit/audit-policy.yaml << 'YAML'
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  - level: RequestResponse
    resources:
      - group: "batch"
        resources: ["cronjobs"]
  - level: Request
    namespaces: ["kube-system"]
    resources:
      - group: "apps"
        resources: ["deployments"]
  - level: Request
    resources:
      - group: ""
      - group: "extensions"
  - level: None
    users: ["system:kube-proxy"]
    verbs: ["watch"]
    resources:
      - group: ""
        resources: ["endpoints", "services"]
YAML

# Add audit flags to API server manifest (if not already there)
if ! grep -q 'audit-log-path' "$MANIFEST"; then
  sed -i '/--anonymous-auth/a\    - --audit-policy-file=/etc/audit/audit-policy.yaml\n    - --audit-log-path=/var/log/kubernetes-logs.log\n    - --audit-log-maxage=5\n    - --audit-log-maxbackup=10\n    - --audit-log-maxsize=100' "$MANIFEST"
fi

# Add volume mounts using sed (not yaml.dump!)
add_apiserver_volume "/etc/audit/audit-policy.yaml" "audit" "true" "/etc/audit/audit-policy.yaml" "File"
add_apiserver_volume "/var/log" "audit-log" "false" "/var/log" "DirectoryOrCreate"

wait_for_apiserver
run_verify "05" "05-audit-logging"
echo ""

# =====================================================================
# Q06 — Dockerfile and Pod Fixes
# =====================================================================
echo -e "${CYAN}Q06: Dockerfile and Pod Fixes${NC}"
sed -i 's/FROM ubuntu:latest/FROM ubuntu:20.04/' /home/candidate/06/Dockerfile
sed -i 's/USER ROOT/USER test-user/' /home/candidate/06/Dockerfile
sed -i 's/runAsUser: 0/runAsUser: 5375/' /home/candidate/06/pod.yaml
sed -i 's/privileged: true/privileged: false/' /home/candidate/06/pod.yaml
run_verify "06" "06-dockerfile-pod-fixes"
echo ""

# =====================================================================
# Q07 — kube-bench Fixes
# =====================================================================
echo -e "${CYAN}Q07: kube-bench Fixes${NC}"
KUBELET_CONFIG="/var/lib/kubelet/config.yaml"
ETCD_MANIFEST="/etc/kubernetes/manifests/etcd.yaml"

# Fix API server: add kubelet-certificate-authority
if ! grep -q '\-\-kubelet-certificate-authority' "$MANIFEST"; then
  sed -i '/--authorization-mode/a\    - --kubelet-certificate-authority=/etc/kubernetes/pki/ca.crt' "$MANIFEST"
fi

# Fix API server: remove or set profiling=false
sed -i 's/--profiling=true/--profiling=false/' "$MANIFEST"

# Fix kubelet: anonymous auth false, webhook mode
sed -i '/anonymous:/,/enabled:/{s/enabled: true/enabled: false/}' "$KUBELET_CONFIG"
sed -i '/authorization:/,/mode:/{s/mode: AlwaysAllow/mode: Webhook/}' "$KUBELET_CONFIG"
systemctl daemon-reload
systemctl restart kubelet

# Fix etcd: remove auto-tls flags
sed -i '/--auto-tls=true/d' "$ETCD_MANIFEST"
sed -i '/--peer-auto-tls=true/d' "$ETCD_MANIFEST"

wait_for_apiserver
run_verify "07" "07-kube-bench"
echo ""

# =====================================================================
# Q08 — Encryption at Rest
# =====================================================================
echo -e "${CYAN}Q08: Encryption at Rest${NC}"

# Generate key and create encryption config
ENC_KEY=$(head -c 32 /dev/urandom | base64)
mkdir -p /etc/kubernetes/enc
cat > /etc/kubernetes/enc/enc.yaml << YAML
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: $ENC_KEY
      - identity: {}
YAML

# Add encryption flag to API server
if ! grep -q 'encryption-provider-config' "$MANIFEST"; then
  sed -i '/--authorization-mode/a\    - --encryption-provider-config=/etc/kubernetes/enc/enc.yaml' "$MANIFEST"
fi

# Add volume mount using sed (not yaml.dump!)
add_apiserver_volume "/etc/kubernetes/enc" "enc" "true" "/etc/kubernetes/enc" "DirectoryOrCreate"

wait_for_apiserver
run_verify "08" "08-encryption-at-rest"
echo ""

# =====================================================================
# Q09 — Stateless/Immutable Pods
# =====================================================================
echo -e "${CYAN}Q09: Stateless and Immutable Pods${NC}"
kubectl delete --grace-period=0 --force pod app -n prod &>/dev/null || true
kubectl delete --grace-period=0 --force pod gcc -n prod &>/dev/null || true
sleep 2
run_verify "09" "09-stateless-immutable-pods"
echo ""

# =====================================================================
# Q10 — RuntimeClass gVisor
# =====================================================================
echo -e "${CYAN}Q10: RuntimeClass gVisor${NC}"
kubectl apply -f - <<'EOF' 2>/dev/null
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: sandboxed
handler: runsc
EOF

for d in workload1 workload2 workload3; do
  kubectl patch deploy "$d" -n server --type=merge \
    -p '{"spec":{"template":{"spec":{"runtimeClassName":"sandboxed"}}}}' &>/dev/null
done
sleep 2
run_verify "10" "10-runtimeclass-gvisor"
echo ""

# =====================================================================
# Q11 — ImagePolicyWebhook
# =====================================================================
echo -e "${CYAN}Q11: ImagePolicyWebhook${NC}"

# Fix defaultAllow
sed -i 's/defaultAllow: true/defaultAllow: false/' /etc/kubernetes/confcontrol/admission_configuration.yaml

# Add ImagePolicyWebhook to admission plugins
if ! grep 'enable-admission-plugins' "$MANIFEST" | grep -q 'ImagePolicyWebhook'; then
  sed -i 's/--enable-admission-plugins=\(.*\)/--enable-admission-plugins=\1,ImagePolicyWebhook/' "$MANIFEST"
fi

# Add admission-control-config-file flag
if ! grep -q 'admission-control-config-file' "$MANIFEST"; then
  sed -i '/--enable-admission-plugins/a\    - --admission-control-config-file=/etc/kubernetes/confcontrol/admission_configuration.yaml' "$MANIFEST"
fi

# Add volume mount using sed (not yaml.dump!)
add_apiserver_volume "/etc/kubernetes/confcontrol" "confcontrol" "true" "/etc/kubernetes/confcontrol" "DirectoryOrCreate"

wait_for_apiserver
run_verify "11" "11-imagepolicy-webhook"
echo ""

# =====================================================================
# Q12 — docker.sock Removal
# =====================================================================
echo -e "${CYAN}Q12: docker.sock Removal${NC}"
kubectl patch deploy docker-hacker -n dev-ops --type=json \
  -p='[
    {"op":"remove","path":"/spec/template/spec/volumes"},
    {"op":"remove","path":"/spec/template/spec/containers/0/volumeMounts"}
  ]' &>/dev/null || true
sleep 3
run_verify "12" "12-docker-sock-removal"
echo ""

# =====================================================================
# Q13 — Istio mTLS
# =====================================================================
echo -e "${CYAN}Q13: Istio mTLS${NC}"

# Create PeerAuthentication CRD (Istio not installed, but we need the CRD for kubectl apply)
kubectl apply -f - <<'EOF' 2>/dev/null
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: peerauthentications.security.istio.io
spec:
  group: security.istio.io
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                mtls:
                  type: object
                  properties:
                    mode:
                      type: string
  scope: Namespaced
  names:
    plural: peerauthentications
    singular: peerauthentication
    kind: PeerAuthentication
    shortNames:
      - pa
EOF
sleep 2

kubectl label namespace payments istio-injection=enabled --overwrite &>/dev/null

kubectl apply -f - <<'EOF' 2>/dev/null
apiVersion: security.istio.io/v1
kind: PeerAuthentication
metadata:
  name: payments-mtls-strict
  namespace: payments
spec:
  mtls:
    mode: STRICT
EOF
sleep 1
run_verify "13" "13-istio-mtls"
echo ""

# =====================================================================
# Q14 — Pod Security Admission
# =====================================================================
echo -e "${CYAN}Q14: Pod Security Admission${NC}"
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
      securityContext:
        runAsNonRoot: true
        runAsUser: 65535
        seccompProfile:
          type: RuntimeDefault
      containers:
      - name: webapp
        image: nginx:1.23
        ports:
        - containerPort: 80
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop: ["ALL"]
        volumeMounts:
        - mountPath: /data
          name: empty-vol
        - mountPath: /var/cache/nginx
          name: cache
        - mountPath: /var/run
          name: run
        - mountPath: /tmp
          name: tmp
      volumes:
      - name: empty-vol
        emptyDir: {}
      - name: cache
        emptyDir: {}
      - name: run
        emptyDir: {}
      - name: tmp
        emptyDir: {}
YAML
kubectl delete deploy webapp -n secure-team --ignore-not-found &>/dev/null || true
sleep 2
kubectl apply -f /home/masters/insecure-deployment.yaml &>/dev/null
kubectl rollout status deploy/webapp -n secure-team --timeout=90s &>/dev/null || true
run_verify "14" "14-pod-security-admission"
echo ""

# =====================================================================
# Q15 — Worker Node Upgrade (Procedure)
# =====================================================================
echo -e "${CYAN}Q15: Worker Node Upgrade Procedure${NC}"
cat > /home/candidate/upgrade-procedure.txt << 'EOF'
# Worker Node Upgrade Procedure

# Step 1: Drain the worker node
kubectl drain node01 --ignore-daemonsets

# Step 2: SSH to the worker
ssh node01
sudo -i

# Step 3: Upgrade kubeadm
sudo apt-mark unhold kubeadm
sudo apt-get update && sudo apt-get install -y kubeadm='1.33.0-*'
sudo apt-mark hold kubeadm

# Step 4: Apply upgrade
sudo kubeadm upgrade node

# Step 5: Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl
sudo apt-get install -y kubelet='1.33.0-*' kubectl='1.33.0-*'
sudo apt-mark hold kubelet kubectl

# Step 6: Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet
exit

# Step 7: Uncordon
kubectl uncordon node01
EOF
run_verify "15" "15-worker-node-upgrade"
echo ""

# =====================================================================
# Q16 — Falco /dev/mem
# =====================================================================
echo -e "${CYAN}Q16: Falco /dev/mem Detection${NC}"
cat > /home/candidate/falco-rule.yaml << 'EOF'
- rule: detect dev mem access
  desc: An attempt to read or write to /dev/mem directory
  condition: >
    ((evt.is_open_read=true or evt.is_open_write=true) and fd.name contains /dev/mem)
  output: >
    Process %proc.name accessed /dev/mem
    (command=%proc.cmdline user=%user.name container=%container.id
    image=%container.image.repository pod_name=%k8s.pod.name
    namespace=%k8s.ns.name)
  priority: WARNING
  tags: [security]
EOF

kubectl scale deployment mem-hacker --replicas=0 -n default &>/dev/null
sleep 2
run_verify "16" "16-falco-devmem"
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
