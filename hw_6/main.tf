module "aws" {
  source = "./aws"
  providers = {
    aws = aws.aws-c1
  }
}

module "azure" {
  source = "./azure"
  providers = {
    azurerm = azurerm.az-1
  }
}