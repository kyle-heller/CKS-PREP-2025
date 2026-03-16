#!/bin/bash
# Solution: User CSR and RBAC
#
# Step 1: Encode the CSR
#   CSR_B64=$(cat /home/candidate/john.csr | base64 | tr -d "\n")
#
# Step 2: Create CertificateSigningRequest resource
#
# cat <<EOF | kubectl apply -f -
# apiVersion: certificates.k8s.io/v1
# kind: CertificateSigningRequest
# metadata:
#   name: john-csr
# spec:
#   request: $CSR_B64
#   signerName: kubernetes.io/kube-apiserver-client
#   expirationSeconds: 86400
#   usages:
#   - client auth
# EOF
#
# Step 3: Approve the CSR
#   kubectl certificate approve john-csr
#
# Step 4: Extract the signed certificate
#   kubectl get csr john-csr -o jsonpath='{.status.certificate}' | base64 -d > /home/candidate/john.crt
#
# Step 5: Set up kubeconfig (optional for this lab)
#   kubectl config set-credentials john \
#     --client-key=/home/candidate/john.key \
#     --client-certificate=/home/candidate/john.crt \
#     --embed-certs=true
#   kubectl config set-context john@kubernetes \
#     --cluster=kubernetes --user=john --namespace=john
#
# Step 6: Create Role
#   kubectl create role john-role \
#     --verb=list,get,create,delete \
#     --resource=pods,secrets \
#     -n john
#
# Step 7: Create RoleBinding
#   kubectl create rolebinding john-role-binding \
#     --role=john-role \
#     --user=john \
#     -n john
#
# Step 8: Verify
#   kubectl auth can-i create pods -n john --as john       # yes
#   kubectl auth can-i create deployments -n john --as john # no
#   kubectl auth can-i delete secrets -n john --as john     # yes
