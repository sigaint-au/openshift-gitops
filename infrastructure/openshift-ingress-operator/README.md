# openshift-ingress-operator

IngressController / default ingress TLS configuration.

| Field | Value |
|-------|-------|
| Clusters | `lhm-prod`, `lhm-dev` |

```bash
kubectl kustomize infrastructure/openshift-ingress-operator/overlays/lhm-dev
oc get ingresscontroller -n openshift-ingress-operator
```
