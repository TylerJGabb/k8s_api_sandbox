data "google_client_config" "current" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.tf-autopilot-cluster.endpoint}"
  token                  = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.tf-autopilot-cluster.master_auth[0].cluster_ca_certificate)
}

resource "kubernetes_namespace" "terraform_managed_namespace" {
  metadata {
    name = "terraform-managed-namespace"
    # annotate the namespace so that CNRM will create
    # resources in this namespace
    annotations = {
      "cnrm.cloud.google.com/project-id" = var.project
    }
  }
}

# It would be nice to enable this in TF. perhaps in a separate phase/group
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest#before-you-use-this-resource

# resource "kubernetes_manifest" "connector_config" {
#   manifest = yamldecode(templatefile("manifests/configconnector.tftpl",
#     {
#       gsa = google_service_account.config_connector_agent.email
#     }
#   ))

#   depends_on = [
#     google_container_cluster.tf-autopilot-cluster
#   ]
# }