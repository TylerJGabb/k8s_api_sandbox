docker build --platform linux/amd64 -t token-generator .
docker tag token-generator us-central1-docker.pkg.dev/a-proj-to-be-deleted/docker-repo/token-generator
docker push us-central1-docker.pkg.dev/a-proj-to-be-deleted/docker-repo/token-generator
