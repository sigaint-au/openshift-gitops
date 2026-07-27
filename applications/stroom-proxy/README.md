# stroom-proxy

GCHQ [Stroom Proxy](https://github.com/gchq/stroom-proxy) deployed with the
[gradata-systems/stroom-helm-charts](https://github.com/gradata-systems/stroom-helm-charts)
`stroom-proxy` Helm chart (image `gchq/stroom-proxy`), pulled from **Quay as an OCI chart**.

| Field | Value |
|-------|-------|
| Cluster | `ocp` |
| App | `app-stroom-proxy` |
| Namespace | `lhm-prod-stroom-proxy` |
| Chart OCI | `oci://quay.sigaint.au/sigaint/stroom-proxy` |
| Chart version | **1.2.14** |
| App version | **v7.10.20** |
| Ingress | OpenShift Route `stroom-proxy.apps.ocp.sigaint.au` (passthrough) |
| Storage | PVC `data` on `ocs-storagecluster-ceph-rbd` (50 Gi) |
| Depends on | Chart in Quay, External Secrets (Doppler), ODF |

```bash
kubectl kustomize --enable-helm applications/stroom-proxy/overlays/ocp
oc get statefulset,svc,route,pvc -n lhm-prod-stroom-proxy
```

## Publish the chart to Quay (OCI)

Upstream only ships a GitHub release tarball (no public Helm/OCI repo). Mirror it into
internal Quay so kustomize / Argo CD can pull it like other Sigaint images.

### Prerequisites

- Helm **≥ 3.8** (OCI support)
- Login to Quay with push rights on `sigaint`:

```bash
# Robot or user with create/push on org "sigaint"
helm registry login quay.sigaint.au -u '<user_or_robot>' -p '<password_or_token>'
# or: podman login quay.sigaint.au
```

### 1. Fetch the upstream chart

```bash
CHART_VERSION=1.2.14
UPSTREAM_TAG=1.2.14-stroom-7.10.20

curl -fsSL -o "stroom-proxy-${CHART_VERSION}.tgz" \
  "https://github.com/gradata-systems/stroom-helm-charts/releases/download/${UPSTREAM_TAG}/stroom-proxy-${CHART_VERSION}.tgz"

# Optional sanity check
tar tzf "stroom-proxy-${CHART_VERSION}.tgz" | head
helm show chart "stroom-proxy-${CHART_VERSION}.tgz"
```

### 2. (Optional) Rebuild from git instead of the release asset

```bash
git clone --depth 1 --branch "${UPSTREAM_TAG}" \
  https://github.com/gradata-systems/stroom-helm-charts.git /tmp/stroom-helm-charts
helm package /tmp/stroom-helm-charts/charts/stroom-proxy -d .
# produces stroom-proxy-1.2.14.tgz from Chart.yaml version
```

### 3. Push as OCI to Quay

```bash
# Pushes to oci://quay.sigaint.au/sigaint/stroom-proxy:1.2.14
helm push "stroom-proxy-${CHART_VERSION}.tgz" oci://quay.sigaint.au/sigaint
```

Quay may require a **Helm chart** (or generic OCI) repository named `stroom-proxy` under the
`sigaint` org the first time; create it if push is denied, then retry.

### 4. Verify pull

```bash
helm pull oci://quay.sigaint.au/sigaint/stroom-proxy --version "${CHART_VERSION}"
helm show chart oci://quay.sigaint.au/sigaint/stroom-proxy --version "${CHART_VERSION}"

kubectl kustomize --enable-helm applications/stroom-proxy/overlays/ocp >/dev/null
```

### 5. Chart upgrades

1. Publish the new version to Quay (same steps, new `CHART_VERSION` / tag).
2. Bump `version` under `helmCharts` in `base/kustomization.yaml`.
3. Align `image.tag` in `base/values.yaml` with the chart `appVersion`.

## Doppler secrets

| Key | Secret | Purpose |
|-----|--------|---------|
| `STROOM_PROXY_TLS_CRT` | `stroom-proxy-tls` → `tls.crt` | Server certificate (PEM) |
| `STROOM_PROXY_TLS_KEY` | `stroom-proxy-tls` → `tls.key` | Private key (PEM) |
| `STROOM_PROXY_TLS_CA` | `stroom-proxy-tls` → `ca.crt` | CA / chain (PEM; **required** by chart init) |
| `STROOM_PROXY_KEYSTORE_PASSWORD` | `stroom-proxy-keystore-password` → `password` | PKCS12 keystore password |

## Configuration notes

- **Forwarding** is off until `stroom.baseUri` points at a real Stroom datafeed. Edit `base/values.yaml` and set `forwarding.enabled: true`.
- **Feed status** stays disabled until an API key ExternalSecret is added.
- **Log sender** sidecar is disabled (privileged container; unsuitable for restricted SCC).
- Chart **Ingress** is disabled; exposure is the OpenShift **Route** (TLS passthrough to port `https` / 8443).
- **Argo CD** must build kustomize with Helm enabled (`kustomize.buildOptions: --enable-helm` on OpenShift GitOps `argocd-cm`) and the application controller must be able to pull from `quay.sigaint.au` (image pull secret / repo credential if the chart repo is private).
