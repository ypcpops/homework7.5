
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0" 
    }
     local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "google" {
  project = "class75-pops"
  region  = "us-central1"
}


