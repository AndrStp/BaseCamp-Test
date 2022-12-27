variable "project_id" {
  type    = string
  default = "vibrant-crawler-372810"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "vm_zone" {
  type    = string
  default = "us-central1-a"
}

variable "vm_image" {
  type = string
}

variable "db_internal" {
  type = string
  default = "192.168.1.2"
}

variable "web_internal" {
  type = string
  default = "192.168.1.3"
}
