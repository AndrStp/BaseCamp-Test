output "ec2_public_ip" {
  value       = aws_instance.grafana[0].public_ip
  description = "AWS EC2 instance public ip"
}
