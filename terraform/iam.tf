resource "google_service_account" "config_connector_agent" {
  account_id = "config-connector-agent"
  depends_on = [google_project_service.enable_apis]
}

resource "google_project_iam_member" "config_connector_perms" {
  for_each = toset([
    "roles/editor",
    "roles/iam.securityAdmin",
    "roles/iam.serviceAccountAdmin"
  ])
  project = var.project
  member  = "serviceAccount:${google_service_account.config_connector_agent.email}"
  role    = each.key
}

resource "google_service_account_iam_binding" "config_connector_cnrm_wi" {
  service_account_id = google_service_account.config_connector_agent.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project}.svc.id.goog[cnrm-system/cnrm-controller-manager]"
  ]
}

output "config_connector_agent_sa_email" {
  value = google_service_account.config_connector_agent.email
}
