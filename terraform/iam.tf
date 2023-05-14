resource "google_service_account" "pod_agent" {
  account_id = "gke-pod-agent"
}

resource "google_project_iam_member" "pod_agent_sa_token_creator" {
  project = var.project
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.pod_agent.email}"
}

# this is tricky...
# https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity#authenticating_to%5Cn
# look at #6
resource "google_service_account_iam_binding" "workload_identity_user" {
  service_account_id = google_service_account.pod_agent.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project}.svc.id.goog[${kubernetes_namespace.terraform_managed_namespace.metadata[0].name}/${kubernetes_service_account.pod_agent.metadata.0.name}]"
  ]
}

output "pod_agent_sa_email" {
  value = google_service_account.pod_agent.email
}

resource "google_service_account" "config_connector_agent" {
  account_id = "config-connector-agent"
}

resource "google_project_iam_member" "config_connector_editor" {
  project = var.project
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.config_connector_agent.email}"
}

resource "google_project_iam_member" "config_connector_sec_admin" {
  project = var.project
  role    = "roles/iam.securityAdmin"
  member  = "serviceAccount:${google_service_account.config_connector_agent.email}"
}


resource "google_project_iam_member" "config_connector_sa_admin" {
  project = var.project
  role    = "roles/iam.serviceAccountAdmin"
  member  = "serviceAccount:${google_service_account.config_connector_agent.email}"
}

resource "google_service_account_iam_binding" "cc_agent_wi_user" {
  service_account_id = google_service_account.config_connector_agent.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project}.svc.id.goog[cnrm-system/cnrm-controller-manager]"
  ]
}

output "cc_agent_sa_email" {
  value = google_service_account.config_connector_agent.email
}

# TODO: move this to better place
output "project" {
  value = var.project
}
