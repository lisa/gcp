variable "project_name" {
  description = "Name of the project"
}

provider "google" {
  credentials = "${file("account.json")}"
  project = "${var.project_name}"
  region = "us-east1"
  zone = "us-east1-b"
}
