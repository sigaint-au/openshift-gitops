# stroom-proxy

GCHQ [Stroom Proxy](https://github.com/gchq/stroom-proxy) deployed with the
[gradata-systems/stroom-helm-charts](https://github.com/gradata-systems/stroom-helm-charts)
`stroom-proxy` Helm chart (image `gchq/stroom-proxy`).

| Field | Value |
|-------|-------|
| Cluster | `ocp` |
| App | `app-stroom-proxy` |
| Namespace | `lhm-prod-stroom-proxy` |
| Chart | `stroom-proxy` **1.2.14** (vendored under `base/helm/`) |
| App version | **v7.10.20** |
| Ingress | OpenShift Route `stroom-proxy.apps.ocp.sigaint.au` (passthrough) |
| Storage | PVC `data` on `ocs-storagecluster-ceph-rbd` (50 Gi) |
| Depends on | External Secrets (Doppler), ODF |

```bash
kubectl kustomize --enable-helm applications/stroom-proxy/overlays/ocp
oc get statefulset,svc,route,pvc -n lhm-prod-stroom-proxy
```

## Doppler secrets

| Key | Secret | Purpose |
|-----|--------|---------|
| `STROOM_PROXY_TLS_CRT` | `stroom-proxy-tls` → `tls.crt` | Server certificate (PEM) |
| `STROOM_PROXY_TLS_KEY` | `stroom-proxy-tls` → `tls.key` | Private key (PEM) |
| `STROOM_PROXY_TLS_CA` | `stroom-proxy-tls` → `ca.crt` | CA / chain (PEM; **required** by chart init) |
| `STROOM_PROXY_KEYSTORE_PASSWORD` | `stroom-proxy-keystore-password` → `password` | PKCS12 keystore password |

## Configuration notes

- **Forwarding** is off until `stroom.baseUri` points at a real Stroom datafeed. Edit `base/values.yaml` (or add an overlay values override) and set `forwarding.enabled: true`.
- **Feed status** checks stay disabled (`stroom.feedStatus.enabled: false`) until an API key ExternalSecret is added.
- **Log sender** sidecar is disabled (chart default uses a privileged container unsuitable for restricted SCC).
- Chart **Ingress** is disabled; exposure is via the OpenShift **Route** (TLS passthrough to port `https` / 8443).
- **Argo CD** must build kustomize with Helm enabled (`kustomize.buildOptions: --enable-helm` on the OpenShift GitOps `argocd-cm` ConfigMap).

## Chart upgrades

```bash
# From a clean tree
curl -sL -o /tmp/stroom-proxy.tgz \
  "https://github.com/gradata-systems/stroom-helm-charts/releases/download/<tag>/stroom-proxy-<ver>.tgz"
rm -rf applications/stroom-proxy/base/helm/stroom-proxy
tar xzf /tmp/stroom-proxy.tgz -C applications/stroom-proxy/base/helm
# Bump image.tag in base/values.yaml to match Chart.appVersion
```

