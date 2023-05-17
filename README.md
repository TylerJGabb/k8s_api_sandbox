# PII Service POC

Here is an image of the planned architecture
![Architecture](./architecture.png)

Its a big lift to automate generation of tables and taxonomy tags with IOC. for now lets just have one table with various columns, and various tags.

| loan_id | ssn         | address       | name        | fico_score | property_state |
| ------- | ----------- | ------------- | ----------- | ---------- | -------------- |
| 1       | 123-45-6789 | 123 Main St   | John Smith  | 725        | CA             |
| 2       | 987-65-4321 | 456 Elm St    | Jane Doe    | 650        | NY             |
| 3       | 543-21-9876 | 789 Oak Ave   | David Lee   | 800        | TX             |
| 4       | 876-54-3210 | 321 Pine St   | Sarah Brown | 690        | FL             |
| 5       | 012-34-5678 | 567 Maple Ave | Alex Chen   | 720        | WA             |

```SQL
CREATE TABLE your_dataset_name.your_table_name (
  loan_id INT64,
  ssn STRING,
  address STRING,
  name STRING,
  fico_score INT64,
  property_state STRING
);

INSERT INTO your_dataset_name.your_table_name (loan_id, ssn, address, name, fico_score, property_state)
VALUES
  (1, '123-45-6789', '123 Main St', 'John Smith', 725, 'CA'),
  (2, '987-65-4321', '456 Elm St', 'Jane Doe', 650, 'NY'),
  (3, '543-21-9876', '789 Oak Ave', 'David Lee', 800, 'TX'),
  (4, '876-54-3210', '321 Pine St', 'Sarah Brown', 690, 'FL'),
  (5, '012-34-5678', '567 Maple Ave', 'Alex Chen', 720, 'WA');
```

Create three tags, one for each column with varying sensitivity

| column  | tag  |
| ------- | ---- |
| ssn     | HIGH |
| address | MED  |
| name    | LOW  |

Then we could have four token generating pods and associated service accounts

| gsa                              | fine-grained reader role on tags |
| -------------------------------- | -------------------------------- |
| gsa-low-reader@example-proj.com  | LOW                              |
| gsa-med-reader@example-proj.com  | MED                              |
| gsa-high-reader@example-proj.com | HIGH                             |
| gsa-all-reader@example-proj.com  | LOW, MED, HIGH                   |

# BigQuery Column Level Security

- https://cloud.google.com/bigquery/docs/column-level-security

## How to enable column level security

- create a dataset and table
- create a taxonomy, toggle on access control
- create tags in that taxonomy
- add principals with the `roles/datacatalog.categoryFineGrainedReader` role to the tags
- add the tags to protected columns in the dataset

## Useful Docs

- https://developer.hashicorp.com/terraform/language/functions/templatefile
- https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/data_catalog_policy_tag_iam
- https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/data_catalog_policy_tag
- AUTOMATION: https://medium.com/@hana.le/how-to-implement-bigquery-policy-tag-with-dbt-and-terraform-e9c935df771f

## Saved queries

```
bq query --nouse_legacy_sql 'select * from `sb-05-386818.multiregion.has_protection`'
bq query --nouse_legacy_sql 'select unprotected from `sb-05-386818.multiregion.has_protection`'
```

# Lessons Learned

1. Make sure output values are correctly copied to the values files
2. It takes a while for config-connector to become fully active in a brand new autopilot cluster. patience is key
3. DO NOT INCLUDE THE IAM POLICY IN THE PROJECT YAML. IT WILL BREAK THE PROJECT
4. https://cloud.google.com/config-connector/docs/troubleshooting
5. https://medium.com/google-cloud/setting-up-config-connector-with-terraform-helm-8ce2f45f48a4
   - autopilot clusters are great, but they also limit addons and features

# Proposed Improvements

1. Use a terraform module to create a regular cluster
   - make sure to configure linked SA properly
   - then you can enable the addon with TF
2. Try to install configconnector on the cluster as an addon manually
   - https://cloud.google.com/config-connector/docs/how-to/install-upgrade-uninstall
   - then try to automate this?

# What is coming next

I've already demonstrated that I can use config connector to create a pod and assign it a workload identity completely with helm.

Its time to expand on this idea, and begin building the rest of the infrastructure: the actual meat of this project which is to show that we can maintain
a list of services to be created, and create associated service accounts and workload identities for them.

# Deploying

1. Create a project in GCP

2. `gcloud auth login` and select the project you just created

3. Enable the APIS

- Identity and Access MAnagaement (IAM) API
- Kubernetes Engine API
- Cloud Resource Manager API
- Service Usage API
- Cloud Billing API

4. Create a service account (optionally named `tf-agent`) with the following roles in IAM

- Kubernetes Engine Service Agent
- Editor
- Security Admin
- Service Account Admin

5. Generate a key for the sa created in step 2 and save it in the root of this repo as `tf-agent-credentials.json`

6. Set the project id in the [terraform.tfvars](./terraform/terraform.tfvars) file

7. Create a new bucket in GCS to store terraform state

8. Set the bucket name in the [main.tf](./terraform/main.tf) file to what you created in step 7

9. Run terraform in the [terraform](./terraform/) directory

```sh
terraform init
terraform plan
terraform apply
```

This will spin up an autopilot cluster, a namespace managed by tf, and a service accounts used by config connector

10. Configure kubectl to access the newly created cluster

- https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl

```sh
gcloud container clusters get-credentials terraform-managed-autopilot-cluster --region=us-central1
kubectl config set-context --current --namespace=terraform-managed-namespace
```

11. Generate values files for the various helm charts

```sh
./generate_values.sh
```

12. Install the config connector to the cluster

Make sure to set the `googleServiceAccount` to the service account created for CC in terraform

```sh
cd helm-charts/configconnector_operator
helm install configconnector.operator .

cd helm-charts/configconnector
helm install configconnector .
```

Wait a while after you do this, it takes a while for the config connector to install. You can wait with the following command:

```sh
kubectl wait -n cnrm-system --for=condition=Ready pod --all
.... time passes
.... even more time passes
pod/cnrm-controller-manager-0 condition met
pod/cnrm-deletiondefender-0 condition met
pod/cnrm-webhook-manager-859b5cd977-kwwm7 condition met
pod/cnrm-webhook-manager-859b5cd977-mglqn condition met
```

14. Import the project as a CNRM managed resource and place it into the helm templates

# DO NOT INCLUDE THE IAM POLICY

```sh
# exporting
config-connector export //cloudresourcemanager.googleapis.com/projects/sb-05-386818 > project.yaml
# omit everything except the first manifest, this avoids the IAMPolicy which is authoritative and dangerous
awk '/---/ {count++} count == 2 {exit} {print}' project.yaml > project.yaml
# add the project
k apply -n terraform-managed-namespace -f project.yaml
```

15. Install the main helm chart

- make sure to add the entry `pii_svc` to the [values.yaml](./helm-charts/main/values.yaml) file

```sh
cat "pii_svc: pii_abc" >> helm-charts/main/values.yaml
cd helm-charts/main
helm install main .
```

# Config Connector

You'll need to install the config connector on your cluster manually, by installing the manifest at [configconnector-operator.yaml](./manifests/configconnector-operator.yaml)

I am following this tutorial to install this on my cluster: https://cloud.google.com/config-connector/docs/how-to/advanced-install#manual

I'm trying to do as much as I can in terraform.

I was able to get the config connector installed and working with terraform. I'm now following https://cloud.google.com/config-connector/docs/how-to/getting-started

Heres a good page to reference for the config connector: https://cloud.google.com/config-connector/docs/how-to/getting-started#whats_next

## Troubleshooting

https://cloud.google.com/config-connector/docs/troubleshooting

# Terraform

I'm currently in the process of trying to manage this infrastructure in terraform so that it can be easily ported for hackday.

## Translating tf output to yaml file for helm values

```

terraform output -json | jq -r 'to_entries[] | "\(.key): \(.value.value)"' > values.yaml

```

# Listing items in GAR

```

gcloud artifacts files list --repository=docker-repo

```

# very important to specify architecture when building image for cloud

```
IMG_NAME=hello-world
docker build --platform linux/amd64 -t $IMG_NAME .
docker tag $IMG_NAME us-central1-docker.pkg.dev/$PROJECT_ID/docker-repo/$IMG_NAME
docker push us-central1-docker.pkg.dev/$PROJECT_ID/docker-repo/$IMG_NAME

```
