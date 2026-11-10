# advanced-cluster-management

Red Hat Advanced Cluster Management (MultiClusterHub) on the lhm-prod cluster.

| Field | Value |
|-------|-------|
| Cluster | `lhm-prod` |
| App | `lhm-prod-advanced-cluster-management` |

```bash
kubectl kustomize infrastructure/advanced-cluster-management/overlays/lhm-prod
oc get multiclusterhub -A
```
