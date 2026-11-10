# compliance-operator

Compliance Operator for OpenShift.

| Field | Value |
|-------|-------|
| Cluster | `lhm-dev` |
| App | `infra-compliance-operator` |

```bash
kubectl kustomize infrastructure/compliance-operator/overlays/lhm-dev
oc get compliancecheckresults -A | head
```
