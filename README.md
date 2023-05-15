# Lessons Learned

1. Make sure output values are correctly copied to the values files
2. It takes a while for config-connector to become fully active in a brand new autopilot cluster. patience is key
3. DO NOT INCLUDE THE IAM POLICY IN THE PROJECT YAML. IT WILL BREAK THE PROJECT
4. https://cloud.google.com/config-connector/docs/troubleshooting

# Deploying

1. Create a project in GCP

2. `gcloud auth login` and select the project you just created

3. Enable the APIS

- Identity and Access MAnagaement (IAM) API
- Kubernetes Engine API
- Cloud Resource Manager API
- Service Usage API
- Cloud Billing API

4. Create a service account (optionally named `tf-agent`) with the following roles in IAM

- Kubernetes Engine Service Agent
- Editor
- Security Admin
- Service Account Admin

5. Generate a key for the sa created in step 2 and save it in the root of this repo as `tf-agent-credentials.json`

6. Set the project id in the [terraform.tfvars](./terraform/terraform.tfvars) file

7. Create a new bucket in GCS to store terraform state

8. Set the bucket name in the [main.tf](./terraform/main.tf) file to what you created in step 7

9. Run terraform in the [terraform](./terraform/) directory

```sh
terraform init
terraform plan
terraform apply
```

This will spin up an autopilot cluster, a namespace managed by tf, and a service accounts used by config connector

10. Configure kubectl to access the newly created cluster

- https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl

```sh
gcloud container clusters get-credentials terraform-managed-autopilot-cluster --region=us-central1
kubectl config set-context --current --namespace=terraform-managed-namespace
```

11. Generate values files for the various helm charts

```sh
./generate_values.sh
```

12. Install the config connector to the cluster

Make sure to set the `googleServiceAccount` to the service account created for CC in terraform

```sh
cd helm-charts/configconnector_operator
helm install configconnector.operator .

cd helm-charts/configconnector
helm install configconnector .
```

Wait a while after you do this, it takes a while for the config connector to install. You can wait with the following command:

```sh
kubectl wait -n cnrm-system --for=condition=Ready pod --all
.... time passes
.... even more time passes
pod/cnrm-controller-manager-0 condition met
pod/cnrm-deletiondefender-0 condition met
pod/cnrm-webhook-manager-859b5cd977-kwwm7 condition met
pod/cnrm-webhook-manager-859b5cd977-mglqn condition met
```

14. Import the project as a CNRM managed resource and place it into the helm templates

# DO NOT INCLUDE THE IAM POLICY

```sh
# exporting
config-connector export //cloudresourcemanager.googleapis.com/projects/sb-05-386818 > project.yaml
# omit everything except the first manifest, this avoids the IAMPolicy which is authoritative and dangerous
awk '/---/ {count++} count == 2 {exit} {print}' project.yaml > project.yaml
# add the project
k apply -n terraform-managed-namespace -f project.yaml
```

15. Install the main helm chart

- make sure to add the entry `pii_svc` to the [values.yaml](./helm-charts/main/values.yaml) file

```sh
cat "pii_svc: pii_abc" >> helm-charts/main/values.yaml
cd helm-charts/main
helm install main .
```

# Config Connector

You'll need to install the config connector on your cluster manually, by installing the manifest at [configconnector-operator.yaml](./manifests/configconnector-operator.yaml)

I am following this tutorial to install this on my cluster: https://cloud.google.com/config-connector/docs/how-to/advanced-install#manual

I'm trying to do as much as I can in terraform.

I was able to get the config connector installed and working with terraform. I'm now following https://cloud.google.com/config-connector/docs/how-to/getting-started

Heres a good page to reference for the config connector: https://cloud.google.com/config-connector/docs/how-to/getting-started#whats_next

## Troubleshooting

https://cloud.google.com/config-connector/docs/troubleshooting

# Terraform

I'm currently in the process of trying to manage this infrastructure in terraform so that it can be easily ported for hackday.

## Translating tf output to yaml file for helm values

```

terraform output -json | jq -r 'to_entries[] | "\(.key): \(.value.value)"' > values.yaml

```

There are two services in this repo. One is a service account lister and the other is a token generator. Both are written in node and are intended to be run as a docker container in GKE.

I've included a script in each director [svc-lister/build_and_push.sh](./svc-lister/build_and_push.sh) and [token_generator/build_and_push.sh](./token_generator/build_and_push.sh) that will build the docker image and push it to GAR.

# Listing items in GAR

```

gcloud artifacts files list --repository=docker-repo

```

# very important to specify architecture when building image for cloud

```

docker build --platform linux/amd64 -t sa-lister .
docker tag sa-lister us-central1-docker.pkg.dev/a-proj-to-be-deleted/docker-repo/sa-lister
docker push us-central1-docker.pkg.dev/a-proj-to-be-deleted/docker-repo/sa-lister

```
