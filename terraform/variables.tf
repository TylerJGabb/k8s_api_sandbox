variable "project" {}

variable "credentials_file" {}

variable "region" {
  default = "us-central1"
}

output "project" {
  value = var.project
}

variable "pii_table" {
  default = "pii_table"
}

variable "pii_dataset" {
  default = "pii_dataset"
}
