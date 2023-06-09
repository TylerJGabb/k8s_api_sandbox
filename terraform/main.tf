terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.65.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.65.2"
    }
  }
  # https://cloud.google.com/docs/terraform/resource-management/store-state
  backend "gcs" {
    bucket = "tf-state-pii-poc"
    prefix = "/foundation"
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project
  region      = var.region
}

provider "google-beta" {
  credentials = file(var.credentials_file)
  project     = var.project
  region      = var.region
}

# maybe, if we can figure out how to do this first before everything else
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service
resource "google_project_service" "enable_apis" {
  project = var.project
  for_each = toset([
    "iam.googleapis.com",
    "container.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudbilling.googleapis.com",
    "bigquery.googleapis.com",
    "datacatalog.googleapis.com",
    "artifactregistry.googleapis.com"
  ])
  timeouts {
    create = "30m"
    update = "30m"
  }

  disable_dependent_services = true
  service                    = each.key
}