# local-storage

Local Storage Operator + LocalVolumeSet (`local-block`) for ODF OSDs.

| Field | Value |
|-------|-------|
| Cluster | `lhm-dev` (lhm-prod has LSO overlays historically) |
| App | `infra-local-storage` |

```bash
kubectl kustomize infrastructure/local-storage/overlays/lhm-dev
oc get localvolumeset,pv -A | head
```
