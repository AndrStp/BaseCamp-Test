data "google_compute_image" "vm_image" {
  family  = "ubuntu-2004-lts"
  project = "ubuntu-os-cloud"
}

