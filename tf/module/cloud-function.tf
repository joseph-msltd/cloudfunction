data "google_storage_bucket" "cf-code-bucket" {
  name = var.management_bucket
}

data "archive_file" "cfzip" {
  type        = "zip"
  output_path = "../tmp/cf.zip"
  source_dir  = "../../cf"
}

resource "google_storage_bucket_object" "cf-code-archive" {
  name   = "cf/cf.zip"
  bucket = data.google_storage_bucket.cf-code-bucket.name
  source = data.archive_file.cfzip.output_path
}

resource "google_cloudfunctions_function" "staging-function" {
  name                  = var.staging_function
  runtime               = "python39"
  source_archive_bucket = data.google_storage_bucket.cf-code-bucket.name
  source_archive_object = google_storage_bucket_object.cf-code-archive.name
  entry_point           = "bq_write"
  max_instances         = 2

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.file-landing-bucket.name
  }

  environment_variables = {
    project_id   = var.project_id
    dataset_name = google_bigquery_dataset.staging-dataset.dataset_id
    table_name   = google_bigquery_table.staging-table.table_id
  }
}