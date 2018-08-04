resource "google_compute_network" "primary_network" {
  name = "primary-network"
}

resource "google_compute_global_address" "public_app_ip" {
  name = "public-ip"
}


output "public_app_ip" {
  value = "${google_compute_global_address.public_app_ip.address}"
}