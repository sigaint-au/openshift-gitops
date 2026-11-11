# access-credentials

SSH public-key secrets for KubeVirt VMs (External Secrets → Doppler).

| Field | Value |
|-------|-------|
| Cluster | `lhm-dev` |
| App | `virt-access-credentials` |

## Secrets (per namespace)

Namespaces: **`lhm-prod-dmz`**, **`lhm-prod-vmnet`**.

> Admin-only public-key Secret (`ssh-pubkey-lhm-admin`, sourced from Doppler `SSH_PUBKEY_LHM_ADMIN`). User key and `-sk` mirrors retired.
>
> IPA enrollment: `ext-ipa-enroll` → Secret `ipa-enroll-userdata` (single `userData` key, synced verbatim from Doppler `IPA_USERDATA`). Consume via `volumes.cloudInitNoCloud.secretRef`. The rendered cloud-config (with credentials) lives in Doppler, not git — the installed ESO CRD schema does not declare `spec.template`, so no in-cluster templating. No secret material in git.

```yaml
# remoteRef (all keys)
conversionStrategy: Default
decodingStrategy: None
metadataPolicy: None
nullBytePolicy: Ignore
```

```bash
kubectl kustomize virtualization/access-credentials/overlays/lhm-dev
oc get externalsecret,secret -n lhm-prod-dmz
oc get externalsecret,secret -n lhm-prod-vmnet
```

### VM accessCredentials

```yaml
accessCredentials:
  - sshPublicKey:
      source:
        secret:
          secretName: ssh-pubkey-lhm-admin
      propagationMethod:
        qemuGuestAgent:
          users: ["admin"]   # guest user
  - sshPublicKey:
      source:
        secret:
          secretName: ssh-pubkey-lhm-user
      propagationMethod:
        qemuGuestAgent:
          users: ["user"]
```
