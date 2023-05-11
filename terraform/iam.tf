resource "google_service_account" "pod_agent" {
  account_id = "gke-pod-agent"
}

resource "google_project_iam_member" "pod_agent_wi_user" {
  project = var.project
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${google_service_account.pod_agent.email}"
}

resource "google_project_iam_member" "pod_agent_sa_token_creator" {
  project = var.project
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.pod_agent.email}"
}

output "pod_agent_sa_email" {
  value = google_service_account.pod_agent.email
}