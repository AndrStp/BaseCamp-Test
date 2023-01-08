provider "aws" {
  region = "eu-central-1"
  alias  = "aws-c1"
}

provider "azurerm" {
  features {}
  alias = "az-1"
}