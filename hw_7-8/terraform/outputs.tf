output "name_ip_key" {
  description = "VMs public IPs"
  value       = aws_instance.my_ec2[*].public_ip
}
