# Readme

## How To Deploy (as of 2021-09-22)

1. Create a project in GCP
2. Create a service account (optionally named `tf-agent`) with the following roles in IAM
   - Kubernetes Engine Service Agent
   - Editor
   - Security Admin
   - Service Account Admin
3. Generate a key for the sa created in step 2 and save it in the root of this repo as `tf-agent-credentials.json`
4. Set the project id in the [terraform.tfvars](./terraform/terraform.tfvars) file

```
project_id = "your-project-id"
```

5. Run terraform in the [terraform](./terraform/) directory

```
terraform init
terraform plan
terraform apply
```

6. Run `./generate_values.sh` from the [root](.) of the repo
7. Install the config connector to the cluster

```
kubectl apply -f manifests/configconnector-operator.yaml
```

8. Install the helm chart by running `helm install $RELEASE_NAME .` in the [manifests](./manifests/) directory

   - note that the config connector k8s resource is in the helm templates, [configconnector.yaml](./manifests/templates/configconnector.yaml) so that this doesn't need to be performed manually

## Config Connector

You'll need to install the config connector on your cluster manually, by installing the manifest at [configconnector-operator.yaml](./manifests/configconnector-operator.yaml)

I am following this tutorial to install this on my cluster: https://cloud.google.com/config-connector/docs/how-to/advanced-install#manual

I'm trying to do as much as I can in terraform.

I was able to get the config connector installed and working with terraform. I'm now following https://cloud.google.com/config-connector/docs/how-to/getting-started

Heres a good page to reference for the config connector: https://cloud.google.com/config-connector/docs/how-to/getting-started#whats_next

## Terraform

I'm currently in the process of trying to manage this infrastructure in terraform so that it can be easily ported for hackday.

### Translating tf output to yaml file for helm values

```
terraform output -json | jq -r 'to_entries[] | "\(.key): \(.value.value)"' > values.yaml
```

There are two services in this repo. One is a service account lister and the other is a token generator. Both are written in node and are intended to be run as a docker container in GKE.

I've included a script in each director [svc-lister/build_and_push.sh](./svc-lister/build_and_push.sh) and [token_generator/build_and_push.sh](./token_generator/build_and_push.sh) that will build the docker image and push it to GAR.

## Listing items in GAR

```
gcloud artifacts files list --repository=docker-repo
```

## very important to specify architecture when building image for cloud

```
docker build --platform linux/amd64 -t sa-lister .
docker tag sa-lister us-central1-docker.pkg.dev/a-proj-to-be-deleted/docker-repo/sa-lister
docker push us-central1-docker.pkg.dev/a-proj-to-be-deleted/docker-repo/sa-lister
```
