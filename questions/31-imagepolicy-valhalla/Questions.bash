# CKS Practice — ImagePolicyWebhook (valhalla)
# Domain: Supply Chain Security (20%)
#
# An ImagePolicyWebhook configuration exists at /etc/kubernetes/imgconfig/
# but is not yet active and has a security misconfiguration.
#
# 1. Fix the admission_configuration.yaml:
#    - Change defaultAllow from true to false (enforce implicit deny)
#
# 2. Edit the kube-apiserver manifest to:
#    - Add ImagePolicyWebhook to --enable-admission-plugins
#    - Add --admission-control-config-file pointing to the admission config
#    - Add volume mount for /etc/kubernetes/imgconfig
#
# 3. Test with: kubectl apply -f /root/16/vulnerable-resource.yaml
#    (should be rejected by the webhook policy)
