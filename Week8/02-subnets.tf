resource "google_compute_subnetwork" "private" {
  name                     = "private-subnet"
  ip_cidr_range            = "10.99.0.0/18"
  region                   = "us-central1"
  network                  = google_compute_network.weekgr8-vpc-network.id
  private_ip_google_access = true

  # IMPORTANT:
  # These CIDR ranges MUST NOT overlap
  # Do not modify unless you understand subnetting


  depends_on = [
    google_compute_network.weekgr8-vpc-network
  ]
}