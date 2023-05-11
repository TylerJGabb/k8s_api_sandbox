terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  credentials = file("../../tf-agent-credentials.json")

  project = "a-proj-to-be-deleted"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"
  tags         = ["web", "dev"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      // Include this section to give the VM an external ip address
      // TODO: create a google_compute_firewall resource to allow external traffic to this VM
      // https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall
    }
  }
}
