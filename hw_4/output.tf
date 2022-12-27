output "web_external_ip" {
  value = google_compute_instance.web_vm.network_interface[0].access_config[0].nat_ip
}

output "db_external_ip" {
  value = google_compute_instance.db_vm.network_interface[0].access_config[0].nat_ip
}
