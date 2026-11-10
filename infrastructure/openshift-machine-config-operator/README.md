# openshift-machine-config-operator

MachineConfig / node config (e.g. auto-sizing reserved).

| Field | Value |
|-------|-------|
| Clusters | `lhm-prod`, `lhm-dev` |

```bash
kubectl kustomize infrastructure/openshift-machine-config-operator/overlays/lhm-dev
oc get mcp
```
