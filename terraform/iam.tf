#locals {
#  gce_service_acct = "service-${google_project.project.number}@compute-system.iam.gserviceaccount.com"
#  gke_service_acct = "service-${google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
#  compute_service_acct = "${google_project.project.number}-compute@developer.gserviceaccount.com"
#}
#
#resource "google_project_iam_member" "allow-gce-automator-to-pull-gcr" {
#  project = "${var.project_id}"
#  role = "roles/storage.objectViewer"
#  member = "serviceAccount:${local.gce_service_acct}"
#}
#
#resource "google_project_iam_member" "allow-gke-automator-to-pull-gcr" {
#  project = "${var.project_id}"
#  role = "roles/storage.objectViewer"
#  member = "serviceAccount:${local.gke_service_acct}"
#}
#
#resource "google_project_iam_member" "allow-default-gce-automator-to-pull-gcr" {
#  project = "${var.project_id}"
#  role = "roles/storage.objectViewer"
#  member = "serviceAccount:${local.compute_service_acct}"
#}

resource "google_service_account" "terraform" {
  account_id = "terraform"
  display_name = "terraform service account"
}