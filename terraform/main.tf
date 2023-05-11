terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
  # https://cloud.google.com/docs/terraform/resource-management/store-state
  backend "gcs" {
    bucket = "e36950d177d19c45-bucket-tfstate"
    prefix = "terraform/state"
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project
  region      = var.region
}

## NOTE: that this was created before adding the `terraform.backend` setting
## You'll need to figure out a better way to initialize the backendfs
resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "default" {
  name          = "${random_id.bucket_prefix.hex}-bucket-tfstate"
  force_destroy = false
  location      = "US"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}