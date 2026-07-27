# stroom-proxy

GCHQ [Stroom Proxy](https://github.com/gchq/stroom-proxy) deployed with the
[gradata-systems/stroom-helm-charts](https://github.com/gradata-systems/stroom-helm-charts)
`stroom-proxy` Helm chart (image `gchq/stroom-proxy`), pulled from **Quay.io as an OCI chart**.

| Field | Value |
|-------|-------|
| Cluster | `ocp` |
| App | `app-stroom-proxy` |
| Namespace | `lhm-prod-stroom-proxy` |
| Chart OCI | `oci://quay.io/sigaint/stroom-proxy:1.2.14` |
| Chart version | **1.2.14** |
| App version | **v7.10.20** |
| Ingress | Chart Ingress host `stroom-proxy.apps.ocp.sigaint.au` (class `openshift-default`) |
| Storage | PVC `data` on `ocs-storagecluster-ceph-rbd` (50 Gi) |
| Depends on | Chart on Quay.io, cert-manager, ODF |

```bash
kubectl kustomize --enable-helm applications/stroom-proxy/overlays/ocp
oc get statefulset,svc,route,pvc -n lhm-prod-stroom-proxy
```

