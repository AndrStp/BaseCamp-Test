variable "ec2_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 VM type"
}

variable "ec2_count" {
  type        = number
  default     = 1
  description = "EC2 VM count"
}

variable "public_key" {
  type        = string
  default     = "../aws-global.pub"
  description = "Location of the public key"
}

variable "private_key" {
  type        = string
  default     = "../aws-global"
  description = "Location of the private key"
}

variable "tags" {
  type = map(string)
  default = {
    "env"     = "test"
    "project" = "global"
  }
  description = "Map of default project tags"
}
