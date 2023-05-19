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
    prefix = "/phase_2"
  }
}

data "terraform_remote_state" "foundation" {
  backend = "gcs"
  config = {
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

output "cluster_endpoint" {
  description = "value of the cluster_endpoint output from the foundation module, which was a separate terraform apply!!!!"
  value       = data.terraform_remote_state.foundation.outputs.cluster_endpoint
}