variable "gke_node_disk_size" {
  default = "10"
  description = "Disk size in GB for GKE member nodes"
}

variable "gke_node_count" {
  default = "3"
  description = "Initial node count for the GKE cluster"
}

variable "gke_node_type" {
  description = "What kind of GCE node type to use for the GKE node pools"
}

resource "google_container_cluster" "primary" {
  name = "cluster"
  initial_node_count = "${var.gke_node_count}"
  network = "${google_compute_network.primary_network.self_link}"  
  
  node_config {
    disk_size_gb = "${var.gke_node_disk_size}"
    machine_type = "${var.gke_node_type}"
    preemptible = true
    tags = [ "gke" ]
    
    oauth_scopes = [
      "compute-rw",
      "storage-ro",
      "logging-write",
      "monitoring",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]
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
