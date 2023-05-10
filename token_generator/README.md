## How to check (via k8s exec) correct gcp-sa is linked to pod (if using workload identity)

```
curl -H "Metadata-Flavor: Google" http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/email
```

## How to test (via k8s exec) generation of token

```
curl -H "Metadata-Flavor: Google" http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/token
```
