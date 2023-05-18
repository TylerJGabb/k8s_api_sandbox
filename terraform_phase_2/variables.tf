variable "project" {}

variable "credentials_file" {}

variable "region" {
  default = "us-central1"
}

output "project" {
  value = var.project
}
