resource "google_container_cluster" "tf-autopilot-cluster" {
  name             = "terraform-managed-autopilot-cluster"
  location         = var.region
  enable_autopilot = true

  # It is an option to enable config connector on a cluster
  # but not for autopilot clusters
  # TODO: provision the cluster without autopilot so that you can enable the 
  # CRDs needed for config connector
  # addons_config {
  #   config_connector_config {
  #     enabled = true
  #   }
  # }

  # workaround for issue with max pods constraint
  # https://github.com/hashicorp/terraform-provider-google/issues/10782#issuecomment-1080195853
  ip_allocation_policy {}
}

output "cluster_endpoint" {
  value = google_container_cluster.tf-autopilot-cluster.endpoint
}

output "cluster_ca_certificate" {
  value = google_container_cluster.tf-autopilot-cluster.master_auth[0].cluster_ca_certificate
}