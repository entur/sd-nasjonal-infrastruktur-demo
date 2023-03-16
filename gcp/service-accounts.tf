resource "google_service_account" "consumer_scope_user" {
  account_id   = "maskinporten-917422575-skyss-1"
  description = "Example service account for scope entur:skyss.1 for orgno 917422575"
}

resource "google_project_iam_member" "workload_identity_sa" {
  project = "ent-data-sdsharing-ext-dev"
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${google_service_account.consumer_scope_user.email}"
}