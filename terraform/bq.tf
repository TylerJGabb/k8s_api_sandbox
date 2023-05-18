resource "google_bigquery_dataset" "main" {
  dataset_id = var.pii_dataset
  location   = var.region
}

resource "google_bigquery_table" "pii_table" {
  dataset_id = google_bigquery_dataset.main.dataset_id
  project    = var.project
  table_id   = var.pii_table
  schema     = <<EOT
    [
        {
            "name": "loan_id",
            "type": "INT64"
        },
        {
            "name": "ssn",
            "type": "STRING"
        },
        {
            "name": "address",
            "type": "STRING"
        },
        {
            "name": "name",
            "type": "STRING"
        },
        {
            "name": "fico_score",
            "type": "INT64"
        },
        {
            "name": "property_state",
            "type": "STRING"
        }
    ]
    EOT

}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_job
resource "google_bigquery_job" "seed_3" {
  job_id   = "seed_3"
  location = var.region
  query {
    use_legacy_sql = false
    destination_table {
      project_id = var.project
      dataset_id = google_bigquery_dataset.main.dataset_id
      table_id   = google_bigquery_table.pii_table.table_id

    }

    query = <<EOT
    (SELECT 1 as loan_id, '123-45-6789' as ssn, '123 Main St' as address, 'John Smith' as name, 725 as fico_score, 'CA' as property_state)
    UNION ALL (select 2, '987-65-4321', '456 Elm St', 'Jane Doe', 650, 'NY')
    UNION ALL (select 3, '543-21-9876', '789 Oak Ave', 'David Lee', 800, 'TX')
    UNION ALL (select 4, '876-54-3210', '321 Pine St', 'Sarah Brown', 690, 'FL')
    UNION ALL (select 5, '012-34-5678', '567 Maple Ave', 'Alex Chen', 720, 'WA');
    EOT
  }
  depends_on = [google_bigquery_dataset.main, google_bigquery_table.pii_table]
}

output "pii_table" {
  value = "${var.project}.${var.pii_dataset}.${var.pii_table}"
}

resource "google_data_catalog_taxonomy" "tf_taxonomy" {
  display_name           = "TF Taxonomy"
  description            = "TF Taxonomy"
  activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]
  depends_on             = [google_bigquery_table.pii_table]
}

resource "google_data_catalog_policy_tag" "basic_policy_tag" {
  taxonomy     = google_data_catalog_taxonomy.tf_taxonomy.id
  display_name = "Low security"
  description  = "A policy tag normally associated with low security items"
}

// https://cloud.google.com/bigquery/docs/column-level-security#set_policy





