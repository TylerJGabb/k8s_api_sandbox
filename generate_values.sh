ROOT=$(PWD)
cd terraform
terraform output -json | jq -r 'to_entries[] | "\(.key): \(.value.value)"' >$ROOT/manifests/values.yaml
