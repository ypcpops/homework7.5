resource "google_compute_network" "week7_vpc" {
  name                    = "week7-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}






#Our subnet configuration
resource "google_compute_subnetwork" "week7_subnet" {
  name          = "week7-subnet"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.week7_vpc.id

}