variable "project_id" {
  description = "Name of the project"
}

variable "gcp_region" {
  description = "GCP Region to use"
}

variable "gcp_zone" {
  description = "GCP Zone to use"
}

variable "google_project_name" {
  description = "Human name of the project"
}

provider "google" {
  credentials = "${file("account.json")}"
  project = "${var.project_id}"
  region = "${var.gcp_region}"
  zone = "${var.gcp_zone}"
}

resource "google_project_services" "services" {
  project = "${var.project_id}"
  services = [
    "bigquery-json.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "deploymentmanager.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "oslogin.googleapis.com",
    "pubsub.googleapis.com",
    "replicapool.googleapis.com",
    "replicapoolupdater.googleapis.com",
    "resourceviews.googleapis.com",
    "serviceusage.googleapis.com",
    "storage-api.googleapis.com",
  ]
}

resource "google_project" "project" {
  name = "${var.google_project_name}"
  project_id = "${var.project_id}"

  lifecycle {
    prevent_destroy = true
  }
}

data "google_project" "project" {}

output "project_number" {
  value = "${data.google_project.project.number}"
}