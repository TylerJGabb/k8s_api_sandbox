resource "google_container_cluster" "tf-autopilot-cluster" {
  name             = "terraform-managed-autopilot-cluster"
  location         = var.region
  enable_autopilot = true

  # workaround for issue with max pods constraint
  # https://github.com/hashicorp/terraform-provider-google/issues/10782#issuecomment-1080195853
  ip_allocation_policy {}
}