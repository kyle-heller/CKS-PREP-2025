# CKS Practice — Role Restriction
# Domain: Cluster Hardening (15%)
#
# Context:
#   Namespace: database
#   ServiceAccount: test-sa (already exists)
#   Role: test-role (bound to test-sa via test-role-binding, overly permissive)
#
# Tasks:
#
# 1. Identify the Role bound to ServiceAccount "test-sa" in namespace "database".
#    (Hint: check RoleBindings in the namespace.)
#    The Role is "test-role".
#
# 2. Edit Role "test-role" to restrict it to ONLY allow the verb "get"
#    on the resource "pods". Remove all other resources and verbs.
#
# 3. Create a new Role named "test-role-2" in namespace "database" that
#    allows ONLY the verb "update" on the resource "statefulsets"
#    (apiGroup: apps).
#
# 4. Create a RoleBinding named "test-role-2-bind" in namespace "database"
#    that binds Role "test-role-2" to ServiceAccount "test-sa".
#
# Verify with:
#   kubectl describe role test-role -n database
#   kubectl describe role test-role-2 -n database
#   kubectl auth can-i get pods --as=system:serviceaccount:database:test-sa -n database
#   kubectl auth can-i update statefulsets --as=system:serviceaccount:database:test-sa -n database
#   kubectl auth can-i delete pods --as=system:serviceaccount:database:test-sa -n database
#   # Last one should return "no"
