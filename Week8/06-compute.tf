resource "google_compute_instance" "vm" {
  name         = "weekgr8-vm"
  machine_type = "n2-standard-2"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-stream-10"
      size  = 100
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private.id
    access_config { # Omitting access config makes VM private. Add argument to make public.

    }
  }

  metadata_startup_script = file("./startup.sh")
}