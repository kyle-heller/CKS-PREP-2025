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
