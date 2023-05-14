# Deploying

## Create a project in GCP

## `gcloud auth login` and select the project you just created

## Enable the APIS

- Identity and Access MAnagaement (IAM) API
- Kubernetes Engine API
- Cloud Resource Manager API
- Service Usage API

## Create a service account (optionally named `tf-agent`) with the following roles in IAM

- Kubernetes Engine Service Agent
- Editor
- Security Admin
- Service Account Admin

## Generate a key for the sa created in step 2 and save it in the root of this repo as `tf-agent-credentials.json`

## Set the project id in the [terraform.tfvars](./terraform/terraform.tfvars) file

## Create a new bucket in GCS to store terraform state

## Set the bucket name in the [main.tf](./terraform/main.tf) file

## Run terraform in the [terraform](./terraform/) directory

```
terraform init
terraform plan
terraform apply
```

## Configure kubectl to access the newly created cluster

- https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl

```
gcloud container clusters get-credentials terraform-managed-autopilot-cluster --region=us-central1
kubectl config set-context --current --namespace=terraform-managed-namespace
```

## Run `./generate_values.sh` from the [root](.) of the repo

## Install the config connector to the cluster

Make sure to set the `googleServiceAccount` to the service account created for CC in terraform

```
kubectl apply -f manifests/configconnector-operator.yaml
```

Wait a while after you do this, it takes a while for the config connector to install. You can wait with the following command:

```
kubectl wait -n cnrm-system --for=condition=Ready pod --all
.... time passes
.... even more time passes
pod/cnrm-controller-manager-0 condition met
pod/cnrm-deletiondefender-0 condition met
pod/cnrm-webhook-manager-859b5cd977-kwwm7 condition met
pod/cnrm-webhook-manager-859b5cd977-mglqn condition met
```

## Import the project as a CNRM managed resource and place it into the helm templates

```
config-connector export //cloudresourcemanager.googleapis.com/projects/$PROJECT_ID > manifests/project.yaml
k apply -f manifests/project.yaml

```

## Install the helm chart by running `helm install $RELEASE_NAME .` in the [manifests](./manifests/) directory

# Config Connector

You'll need to install the config connector on your cluster manually, by installing the manifest at [configconnector-operator.yaml](./manifests/configconnector-operator.yaml)

I am following this tutorial to install this on my cluster: https://cloud.google.com/config-connector/docs/how-to/advanced-install#manual

I'm trying to do as much as I can in terraform.

I was able to get the config connector installed and working with terraform. I'm now following https://cloud.google.com/config-connector/docs/how-to/getting-started

Heres a good page to reference for the config connector: https://cloud.google.com/config-connector/docs/how-to/getting-started#whats_next

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
