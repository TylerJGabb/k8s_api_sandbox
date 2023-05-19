resource "google_data_catalog_policy_tag_iam_member" "policy_tag_iam_high" {
  policy_tag = data.terraform_remote_state.foundation.outputs.high_policy_tag_name
  member     = "serviceAccount:${each.value}"
  role       = "roles/datacatalog.categoryFineGrainedReader"
  for_each = toset([
    "all-gsa@${var.project}.iam.gserviceaccount.com",
    "high-gsa@${var.project}.iam.gserviceaccount.com",
  ])
}

resource "google_data_catalog_policy_tag_iam_member" "policy_tag_iam_med" {
  policy_tag = data.terraform_remote_state.foundation.outputs.med_policy_tag_name
  member     = "serviceAccount:${each.value}"
  role       = "roles/datacatalog.categoryFineGrainedReader"
  for_each = toset([
    "all-gsa@${var.project}.iam.gserviceaccount.com",
    "med-gsa@${var.project}.iam.gserviceaccount.com",
  ])
}

resource "google_data_catalog_policy_tag_iam_member" "policy_tag_iam_low" {
  policy_tag = data.terraform_remote_state.foundation.outputs.low_policy_tag_name
  member     = "serviceAccount:${each.value}"
  role       = "roles/datacatalog.categoryFineGrainedReader"
  for_each = toset([
    "all-gsa@${var.project}.iam.gserviceaccount.com",
    "low-gsa@${var.project}.iam.gserviceaccount.com",
  ])
}

resource "google_bigquery_datapolicy_data_policy_iam_member" "masked_reader_low" {
  data_policy_id = data.terraform_remote_state.foundation.outputs.low_masking_data_policy_id
  location       = var.region
  member         = "serviceAccount:${each.value}"
  role           = "roles/bigquerydatapolicy.maskedReader"
  for_each = toset([
    "med-gsa@${var.project}.iam.gserviceaccount.com",
    "high-gsa@${var.project}.iam.gserviceaccount.com",
  ])
}

//one for med
resource "google_bigquery_datapolicy_data_policy_iam_member" "masked_reader_med" {
  data_policy_id = data.terraform_remote_state.foundation.outputs.med_masking_data_policy_id
  location       = var.region
  member         = "serviceAccount:${each.value}"
  role           = "roles/bigquerydatapolicy.maskedReader"
  for_each = toset([
    "low-gsa@${var.project}.iam.gserviceaccount.com",
    "high-gsa@${var.project}.iam.gserviceaccount.com",
  ])
}

//and one for high
resource "google_bigquery_datapolicy_data_policy_iam_member" "masked_reader_high" {
  data_policy_id = data.terraform_remote_state.foundation.outputs.high_masking_data_policy_id
  location       = var.region
  member         = "serviceAccount:${each.value}"
  role           = "roles/bigquerydatapolicy.maskedReader"
  for_each = toset([
    "low-gsa@${var.project}.iam.gserviceaccount.com",
    "med-gsa@${var.project}.iam.gserviceaccount.com",
  ])
}