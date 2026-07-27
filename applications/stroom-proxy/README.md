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

## Publish the chart to Quay.io (OCI)

Upstream only ships a GitHub release tarball (no public Helm/OCI repo). Mirror it to
`oci://quay.io/sigaint/stroom-proxy` so kustomize / Argo CD can pull it.

### Prerequisites

- Helm **≥ 3.8** (OCI support)
- Login to Quay.io with push rights on org `sigaint`:

```bash
# Robot or user with create/push on org "sigaint"
helm registry login quay.io -u '<user_or_robot>' -p '<password_or_token>'
# or: podman login quay.io
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

### 3. Push as OCI to Quay.io

```bash
# Pushes to oci://quay.io/sigaint/stroom-proxy:1.2.14
helm push "stroom-proxy-${CHART_VERSION}.tgz" oci://quay.io/sigaint
```

Quay may require a **public/private repository** named `stroom-proxy` under the `sigaint`
org the first time; create it if push is denied, then retry.

Helper script (same defaults): `/tmp/script.sh`

```bash
QUAY_USER='sigaint+robot' QUAY_PASS='***' /tmp/script.sh
```

### 4. Verify pull

```bash
helm pull oci://quay.io/sigaint/stroom-proxy --version "${CHART_VERSION}"
helm show chart oci://quay.io/sigaint/stroom-proxy --version "${CHART_VERSION}"

kubectl kustomize --enable-helm applications/stroom-proxy/overlays/ocp >/dev/null
```

### 5. Chart upgrades

1. Publish the new version to Quay.io (same steps, new `CHART_VERSION` / tag).
2. Bump `version` under `helmCharts` in `base/kustomization.yaml`.
3. Align `image.tag` in `base/values.yaml` with the chart `appVersion`.

## TLS (cert-manager)

No External Secrets. A private CA is bootstrapped in-namespace so the leaf Secret
includes **`ca.crt`** (required by the chart keystore/truststore init). ACME
issuers like `le-production` do not put `ca.crt` in the Secret.

| Resource | Role |
|----------|------|
| `Issuer/stroom-proxy-selfsigned` | Self-signed root |
| `Certificate/stroom-proxy-ca` | CA cert → Secret `stroom-proxy-ca` |
| `Issuer/stroom-proxy-ca-issuer` | Signs leaf from that CA |
| `Certificate/stroom-proxy-tls` | Leaf for `stroom-proxy.apps.ocp.sigaint.au` → Secret `stroom-proxy-tls` |

Clients must trust the CA in Secret `stroom-proxy-ca` (or switch the leaf
`issuerRef` to a public ClusterIssuer and supply `ca.crt` another way).

## Keystore password

| Source | Secret | Purpose |
|--------|--------|---------|
| `base/values.yaml` `keystorePassword` | `stroom-proxy-keystore-password` → `password` | PKCS12 password (**example** `changeme`) |

The chart only accepts the password via `secretKeyRef`. The example value is
mirrored in `overlays/ocp/keystore-password-secret.yaml`. Replace both before production.

## Configuration notes

- **Forwarding** is off until `stroom.baseUri` points at a real Stroom datafeed. Edit `base/values.yaml` and set `forwarding.enabled: true`.
- **Feed status** stays disabled until an API key is configured.
- **Log sender** sidecar is disabled (privileged container; unsuitable for restricted SCC).
- Exposure is via the chart **Ingress** (`ingress.enabled: true`, host `stroom-proxy.apps.ocp.sigaint.au`). The chart sets nginx-style body-size / backend-protocol annotations; adjust `ingress.annotations` / `className` if your controller differs.
- **Argo CD** must build kustomize with Helm enabled (`kustomize.buildOptions: --enable-helm` on OpenShift GitOps `argocd-cm`) and pull from `quay.io` (repo credential if the chart is private).
