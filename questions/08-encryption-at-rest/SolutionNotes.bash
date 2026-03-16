#!/bin/bash
# Solution: Encryption at Rest
#
# Step 1: Generate a 32-byte encryption key
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
#                 secret: <paste-base64-key-here>
#         - identity: {}
#
#   Provider order matters: the FIRST provider is used for encryption.
#   identity: {} as a fallback allows reading unencrypted secrets during migration.
#
# Step 3: Edit /etc/kubernetes/manifests/kube-apiserver.yaml
#   Add flag:
#     - --encryption-provider-config=/etc/kubernetes/enc/enc.yaml
#
#   Add volume mount:
#     volumeMounts:
#     - name: enc
#       mountPath: /etc/kubernetes/enc
#       readOnly: true
#
#   Add volume:
#     volumes:
#     - name: enc
#       hostPath:
#         path: /etc/kubernetes/enc
#         type: DirectoryOrCreate
#
#   Wait for API server to restart (~30 seconds).
#
# Step 4: Verify with etcdctl
#   ETCDCTL_API=3 etcdctl \
#     --cacert=/etc/kubernetes/pki/etcd/ca.crt \
#     --cert=/etc/kubernetes/pki/etcd/server.crt \
#     --key=/etc/kubernetes/pki/etcd/server.key \
#     get /registry/secrets/default/test-unencrypted | hexdump -C
#
#   Before encryption: you'll see plaintext key/value data.
#   After encryption: you'll see 'k8s:enc:aescbc:v1:key1' prefix + binary data.
#
# Step 5: Re-encrypt all existing secrets
#   kubectl get secrets --all-namespaces -o json | kubectl replace -f -
#
#   This reads each secret and writes it back, causing re-encryption with
#   the new provider. Without this, old secrets remain in plaintext in etcd.
#
# Notes:
#   - aescbc is the recommended provider for production encryption at rest
#   - The encryption key must be safely backed up and rotated periodically
#   - aesgcm is faster but considered less secure for key management
#   - secretbox is the newest option (K8s 1.27+), uses XSalsa20+Poly1305
