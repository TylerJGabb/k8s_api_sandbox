ROOT=$(PWD)
cd terraform
terraform output -json | jq -r 'to_entries[] | "\(.key): \(.value.value)"' >>$ROOT/helm-charts/main/values.yaml
terraform output -json | jq -r 'to_entries[] | "\(.key): \(.value.value)"' >$ROOT/helm-charts/configconnector/values.yaml
