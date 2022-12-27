terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.47.0"
    }
  }
}

locals {
  vm_image = var.vm_image != "" ? var.vm_image : data.google_compute_image.vm_image.self_link
}

resource "google_compute_network" "vpc_network" {
  name                    = "my-global-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "my_subnet" {
  name          = "my-subnet"
  ip_cidr_range = "192.168.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_address" "db_internal" {
  name         = "db-internal"
  subnetwork   = google_compute_subnetwork.my_subnet.id
  address_type = "INTERNAL"
  address      = var.db_internal
  region       = var.region
}

resource "google_compute_address" "web_internal" {
  name         = "web-internal"
  subnetwork   = google_compute_subnetwork.my_subnet.id
  address_type = "INTERNAL"
  address      = var.web_internal
  region       = var.region
}

resource "google_compute_firewall" "ssh" {
  name          = "ssh-firewall"
  network       = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["ssh"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "web" {
  name          = "web-firewall"
  network       = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  target_tags = ["web"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "db" {
  name          = "db-firewall"
  network       = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["3300-3400"]
  }

  target_tags = ["db"]
  source_ranges = ["192.168.1.0/24"]
}

resource "google_compute_instance" "web_vm" {
  name         = "web"
  machine_type = "e2-micro"
  zone         = var.vm_zone

  tags = ["web", "ssh"]

  boot_disk {
    initialize_params {
      image = local.vm_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.my_subnet.name
    network_ip = google_compute_address.web_internal.address
    access_config {
    }
  }

  metadata = {
    ssh-keys = "andrey:${file("./global.pub")}"
  }

  metadata_startup_script = "${file("./web_bootstrap.sh")}"
}

resource "google_compute_instance" "db_vm" {
  name         = "db"
  machine_type = "e2-micro"
  zone         = var.vm_zone

  tags = ["db", "ssh"]

  boot_disk {
    initialize_params {
      image = local.vm_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.my_subnet.name
    network_ip = google_compute_address.db_internal.address
    access_config {
    }
  }

  metadata = {
    ssh-keys = "andrey:${file("./global.pub")}"
  }

  metadata_startup_script = "${file("./db_bootstrap.sh")}"
}
