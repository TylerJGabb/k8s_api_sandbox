# Manifests

## Installing config connector operator

Install the manifest at [configconnector-operator.yaml](./configconnector-operator.yaml)

## How to generate values files

1. run the shell script `generate_values.sh` from the root of the repo
2. this will run terraform apply to produce outputs, and use said outputs to generate a values file
