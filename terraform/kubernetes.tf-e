variable "gke_node_disk_size" {
  default = "10"
  description = "Disk size in GB for GKE member nodes"
}

variable "gke_node_count" {
  default = "3"
  description = "Initial node count for the GKE cluster"
}

resource "google_container_cluster" "primary" {
  name = "cluster"
  initial_node_count = 3
  network = "${google_compute_network.primary_network.self_link}"  
  
  node_config {
    disk_size_gb = "10"
    machine_type = "f1-micro"
    preemptible = true
    tags = [ "gke" ]
  }
  
}

output "client_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.client_certificate}"
}

output "client_key" {
  value = "${google_container_cluster.primary.master_auth.0.client_key}"
}

output "cluster_ca_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
}
