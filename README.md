# Readme

There are two services in this repo. One is a service account lister and the other is a token generator. Both are written in node and are intended to be run as a docker container in GKE.

I've included a script in each director [svc-lister/build_and_push.sh](./svc-lister/build_and_push.sh) and [token_generator/build_and_push.sh](./token_generator/build_and_push.sh) that will build the docker image and push it to GAR.

## Listing items in GAR

```
us-central1-docker.pkg.dev/a-proj-to-be-deleted/docker-repo/sa-lister
gcloud artifacts files list --repository=docker-repo
```

## very important to specify architecture when building image for cloud

```
docker build --platform linux/amd64 -t sa-lister .
docker tag sa-lister us-central1-docker.pkg.dev/a-proj-to-be-deleted/docker-repo/sa-lister
docker push us-central1-docker.pkg.dev/a-proj-to-be-deleted/docker-repo/sa-lister
```
