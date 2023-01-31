resource "google_bigquery_dataset" "staging-dataset" {
  dataset_id = var.staging_dataset_name
  location   = var.region
}

resource "google_bigquery_table" "staging-table" {
  dataset_id          = google_bigquery_dataset.staging-dataset.dataset_id
  table_id            = var.staging_table
  deletion_protection = false
  schema              = file("../schema/persons.json")
}