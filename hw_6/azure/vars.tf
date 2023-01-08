variable "rg_name" {
  type        = string
  default     = "global-rg"
  description = "Azure resource group name"
}

variable "rg_location" {
  type        = string
  default     = "westeurope"
  description = "Azure resource group location"
}

variable "vm_type" {
  type        = string
  default     = "Standard_B1ls"
  description = "VM instance type"
}

variable "public_key" {
  type        = string
  default     = "./data/az-global.pub"
  description = "Location of the public key"
}

variable "tags" {
  type = map(string)
  default = {
    "Name"    = "global_test"
    "env"     = "test"
    "project" = "global"
  }
  description = "Set of default project tags"
}
