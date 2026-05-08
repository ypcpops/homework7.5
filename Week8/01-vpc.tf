# DO NOT TOUCH

resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
  disable_on_destroy = false
}



# DO NOT TOUCH
resource "google_project_service" "container" {
  service = "container.googleapis.com"
  disable_on_destroy = false
}


resource "google_compute_network" "weekgr8-vpc-network" {
  name                    = "weekgr8-vpc-network"
  auto_create_subnetworks = false # Set to true by deafult, we want to create our own subnets, so set to false.
  mtu                     = 1460
}

# Subnet Config
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork

resource "google_compute_subnetwork" "weekgr8-vpc-subnetwork" {
  name          = "weekgr8-vpc-subnet"
  ip_cidr_range = "10.13.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.weekgr8-vpc-network.id
}