# loki-operator

Loki Operator in global namespace `openshift-operators-redhat`.

| Field | Value |
|-------|-------|
| Cluster | `lhm-dev` |
| App | `infra-loki-operator` |
| Channel | `stable-6.6` |

```bash
kubectl kustomize infrastructure/loki-operator/overlays/lhm-dev
oc get csv -n openshift-operators-redhat
```

Package owns Namespace + OperatorGroup + Subscription.
