# openshift-apiserver-operator

API server TLS / configuration overlays.

| Field | Value |
|-------|-------|
| Clusters | `lhm-prod`, `lhm-dev` |

```bash
kubectl kustomize infrastructure/openshift-apiserver-operator/overlays/lhm-dev
kubectl kustomize infrastructure/openshift-apiserver-operator/overlays/lhm-prod
```
