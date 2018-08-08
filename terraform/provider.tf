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

variable "google_billing_account" {
  description = "Google Billing Account for google_project"
}

provider "google" {
  credentials = "${file("account.json")}"
  project     = "${var.project_id}"
  region      = "${var.gcp_region}"
  zone        = "${var.gcp_zone}"
}

resource "google_project_services" "services" {
  project = "${var.project_id}"
  services = [
    "appengine.googleapis.com",
    "bigquery-json.googleapis.com",
    "cloudbilling.googleapis.com",
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
  depends_on = [
    "google_service_account.terraform",
  ]
  
}

resource "google_project" "project" {
  name = "${var.google_project_name}"
  project_id = "${var.project_id}"

  lifecycle {
    prevent_destroy = true
  }
}

data "google_project" "project" {
  billing_account = "${var.google_billing_account}"

  lifecycle {
    prevent_destroy = true
  }
}