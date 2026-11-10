# cloudnative-pg-operator

CloudNativePG operator (Quay database).

| Field | Value |
|-------|-------|
| Cluster | `lhm-dev` |
| App | `infra-cloudnative-pg-operator` |

```bash
kubectl kustomize infrastructure/cloudnative-pg-operator/overlays/lhm-dev
oc get csv -n openshift-operators | grep cloudnative
```
