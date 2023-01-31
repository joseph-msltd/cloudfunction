terraform {
  backend "gcs" {
    bucket = "<project_id>-management"
    prefix = "terraform/cloudfunction/state"
  }
  required_version = "1.3.7"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

