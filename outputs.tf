output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "bastion_public_ip" {
  description = "Bastion Host Public IP"
  value       = aws_instance.bastion.public_ip
}

output "nginx_server_public_ip" {
  description = "Nginx Server Public IP"
  value       = aws_instance.nginx_server.public_ip
}

output "server_domain" {
  description = "Server Domain Name"
  value       = local.server_domain
}