Pushing to GAR
https://cloud.google.com/artifact-registry/docs/docker/pushing-and-pulling
us-central1-docker.pkg.dev/a-proj-to-be-deleted/docker-repo/sa-lister
gcloud artifacts files list --repository=docker-repo
docker build --platform linux/amd64 -t sa-lister .
docker tag sa-lister us-central1-docker.pkg.dev/a-proj-to-be-deleted/docker-repo/sa-lister
docker push us-central1-docker.pkg.dev/a-proj-to-be-deleted/docker-repo/sa-lister
