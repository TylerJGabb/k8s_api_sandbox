resource "google_artifact_registry_repository" "docker-repo" {
  repository_id = "docker-repo"
  location      = var.region
  format        = "DOCKER"
  description   = "Docker repository"

  depends_on = [google_project_service.enable_apis["artifactregistry.googleapis.com"]]

}

output "docker-repo-id" {
  value = google_artifact_registry_repository.docker-repo.id
}