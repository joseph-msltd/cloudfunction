resource "google_storage_bucket" "file-landing-bucket" {
  name          = var.landing_bucket_name
  project       = var.project_id
  location      = var.region
  storage_class = "REGIONAL"
  force_destroy = true
}