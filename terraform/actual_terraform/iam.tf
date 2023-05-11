# resource "google_service_account" "main_sa" {
#   account_id = "gke-pod-agent"
# }

# resource "google_project_iam_member" "pod_agent_editor" {
#   project = var.project
#   role    = "roles/Editor"
#   member  = "serviceAccount:${google_service_account.main_sa.email}"
# }