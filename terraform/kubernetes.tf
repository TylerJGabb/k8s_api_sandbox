data "google_client_config" "current" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.tf-autopilot-cluster.endpoint}"
  token                  = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.tf-autopilot-cluster.master_auth[0].cluster_ca_certificate)
}

resource "kubernetes_namespace" "terraform_managed_namespace" {
  metadata {
    name = "terraform-managed-namespace"
    annotations = {
      "cnrm.cloud.google.com/project-id" = var.project
    }
  }
}

resource "kubernetes_service_account" "pod_agent" {
  metadata {
    name      = "pod-agent"
    namespace = kubernetes_namespace.terraform_managed_namespace.metadata[0].name
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.pod_agent.email
    }
  }
}

resource "kubernetes_role" "service_lister" {
  metadata {
    name      = "service_lister"
    namespace = kubernetes_namespace.terraform_managed_namespace.metadata[0].name
  }
  rule {
    api_groups = [""]
    resources  = ["services"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "pod_agent_service_lister" {
  metadata {
    name      = "pod-agent-service-lister"
    namespace = kubernetes_namespace.terraform_managed_namespace.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.service_lister.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.pod_agent.metadata[0].name
    namespace = kubernetes_namespace.terraform_managed_namespace.metadata[0].name
  }

}

output "k8s_pod_agent_service_account_name" {
  value = kubernetes_service_account.pod_agent.metadata[0].name
}