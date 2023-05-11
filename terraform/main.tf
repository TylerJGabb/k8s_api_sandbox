terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
  # https://cloud.google.com/docs/terraform/resource-management/store-state
  backend "gcs" {
    bucket = "tfstate-000001"
    prefix = "terraform/state"
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project
  region      = var.region
}