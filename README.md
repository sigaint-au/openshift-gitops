# sigaint-iac

[![validate](https://github.com/sigaint-au/sigaint-iac/actions/workflows/validate.yaml/badge.svg)](https://github.com/sigaint-au/sigaint-iac/actions/workflows/validate.yaml)

| Cluster | Bootstrap |
|---------|-----------|
| `hub` | `clusters/hub/bootstrap/` |
| `ocp` | `clusters/ocp/bootstrap/` |

| Cluster | AppProjects |
|---------|-------------|
| `hub` | `infrastructure` |
| `ocp` | `infrastructure`, `applications`, `virtualization` |

Workload / virt namespaces: `lhm-<env>-*` (e.g. `lhm-prod-quay`).

Repo: `https://github.com/sigaint-au/sigaint-iac`

## Bootstrap

Apply only this cluster’s bootstrap on that cluster.

```bash
git clone https://github.com/sigaint-au/sigaint-iac.git && cd sigaint-iac
```

### 1. OpenShift GitOps

```bash
oc apply -f - <<'EOF'
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-gitops-operator
  namespace: openshift-operators
spec:
  channel: latest
  name: openshift-gitops-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  installPlanApproval: Automatic
EOF

oc wait --for=condition=Available deployment/openshift-gitops-server \
  -n openshift-gitops --timeout=300s

oc get route openshift-gitops-server -n openshift-gitops \
  -o jsonpath='https://{.spec.host}{"\n"}'
```

### 2. Enable Helm for Kustomize

Required for apps that use `helmCharts` (e.g. stroom-proxy). Patch the default `ArgoCD` CR:

```bash
oc patch argocd openshift-gitops -n openshift-gitops --type merge \
  -p '{"spec":{"kustomizeBuildOptions":"--enable-helm"}}'
```

Equivalent:

```yaml
apiVersion: argoproj.io/v1beta1
kind: ArgoCD
metadata:
  name: openshift-gitops
  namespace: openshift-gitops
spec:
  kustomizeBuildOptions: --enable-helm
```

### 3. Day-0 RBAC (optional)

```bash
oc apply -f - <<'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: argocd-cluster-admin
subjects:
  - kind: ServiceAccount
    name: openshift-gitops-argocd-application-controller
    namespace: openshift-gitops
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
EOF
```

Remove after AppProjects and apps are healthy:

```bash
oc delete clusterrolebinding argocd-cluster-admin
```

### 4. Root application

**ocp**

```bash
oc apply -f clusters/ocp/bootstrap/appprojects.yaml
oc apply -f clusters/ocp/bootstrap/root-application.yaml
oc get appprojects,application -n openshift-gitops
```

**hub**

```bash
oc apply -f clusters/hub/bootstrap/appprojects.yaml
oc apply -f clusters/hub/bootstrap/root-application.yaml
oc get appprojects,application -n openshift-gitops
```

### 5. External Secrets (Doppler)

```bash
oc create namespace external-secrets --dry-run=client -o yaml | oc apply -f -

oc create secret generic doppler-token-auth-api \
  --namespace external-secrets \
  --from-literal=dopplerToken='dp.st.REPLACE_ME' \
  --dry-run=client -o yaml | oc apply -f -
```

Template: `infrastructure/openshift-external-secrets-operator/overlays/<cluster>/doppler-secret.yaml.example`

### 6. Verify

```bash
oc get application,applicationset -n openshift-gitops
oc get application -n openshift-gitops | grep -E '^(hub|infra|app|virt)-'
```
