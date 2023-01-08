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
  default     = "./data/aws-global.pub"
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
