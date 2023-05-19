data "google_client_config" "current" {}

provider "kubernetes" {
  host                   = "https://${data.terraform_remote_state.foundation.outputs.cluster_endpoint}"
  token                  = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(data.terraform_remote_state.foundation.outputs.cluster_ca_certificate)
}


