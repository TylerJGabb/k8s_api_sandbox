# Readme

## Config Connector

You'll need to install the config connector on your cluster manually, by installing the manifest at [configconnector-operator.yaml](./manifests/configconnector-operator.yaml)

I am following this tutorial to install this on my cluster: https://cloud.google.com/config-connector/docs/how-to/advanced-install#manual

I'm trying to do as much as I can in terraform.

I was able to get the config connector installed and working with terraform. I'm now following https://cloud.google.com/config-connector/docs/how-to/getting-started

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
