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