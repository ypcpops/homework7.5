terraform {
  required_version = "~> 1.10"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}
# Replace the project with your own.
provider "google" {
  # Configuration options
  project = "class75-pops"
  region  = "us-central1"
}