output "aws_public_ip" {
  value = module.aws.ec2_public_ip
}

output "az_public_ip" {
    value = module.azure.vm_public_ip
}
