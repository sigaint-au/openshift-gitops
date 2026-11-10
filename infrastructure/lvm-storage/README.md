# lvm-storage

LVM Storage (Topolvm) for lhm-prod local volumes.

| Field | Value |
|-------|-------|
| Cluster | `lhm-prod` |
| App | `lhm-prod-lvm-storage` |

```bash
kubectl kustomize infrastructure/lvm-storage/overlays/lhm-prod
oc get lvmcluster -A
```
