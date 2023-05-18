PROJECT=$(gcloud config get-value project)
IMG_NAME=query-runner
REPO="us-central1-docker.pkg.dev/$PROJECT/docker-repo"
VERSION="1.0.9"
TAG="${REPO}/${IMG_NAME}:${VERSION}"
docker build --platform linux/amd64 -t $TAG .
docker push $TAG
echo $TAG
