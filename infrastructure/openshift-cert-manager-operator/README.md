# openshift-cert-manager-operator

cert-manager (Red Hat) for certificates / issuers.

| Field | Value |
|-------|-------|
| Clusters | `lhm-prod`, `lhm-dev` |

```bash
kubectl kustomize infrastructure/openshift-cert-manager-operator/overlays/lhm-dev
oc get certificate -A | head
```
