# access-credentials

SSH public-key secrets for KubeVirt VMs (External Secrets → Doppler).

| Field | Value |
|-------|-------|
| Cluster | `lhm-dev` |
| App | `virt-access-credentials` |

## Secrets (per namespace)

Namespaces: **`lhm-prod-dmz`**, **`lhm-prod-vmnet`**.

> IPA enrollment retired — did not behave as expected. Public-key Secret only.
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
