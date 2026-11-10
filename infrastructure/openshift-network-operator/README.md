# openshift-network-operator

Cluster Network Operator (`Network` CR) — OVN gateway + cluster MTU.

| Field | Value |
|-------|-------|
| Cluster | `lhm-dev` |
| App | `infra-openshift-network-operator` |

| Setting | Value |
|---------|-------|
| OVN MTU | CNO default (8900 deferred — needs post-install migration procedure) |
| `routingViaHost` | `true` |
| `ipForwarding` | `Global` |

```bash
kubectl kustomize infrastructure/openshift-network-operator/overlays/lhm-dev
oc get network.operator cluster \
  -o jsonpath='{.spec.defaultNetwork.ovnKubernetesConfig.mtu}{"\n"}'
```

Secondary NIC MTU: `infrastructure/nmstate/`.
