provider "google" {
  credentials = file("my_gcp_id.json")

  project = var.project_id
  region  = var.region
}
