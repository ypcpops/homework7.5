resource "google_compute_router" "router" {
  name    = "router"
  region  = "us-central1"
  network = google_compute_network.weekgr8-vpc-network.id

  
  depends_on = [
    google_compute_network.weekgr8-vpc-network
  ]
}