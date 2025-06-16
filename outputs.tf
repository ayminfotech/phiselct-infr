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

output "jenkins_server_private_ip" {
  description = "Jenkins Server Private IP"
  value       = aws_instance.jenkins_server.private_ip
}

output "nginx_server_private_ip" {
  description = "Nginx Server Private IP"
  value       = aws_instance.nginx_server.private_ip
}

output "application_server_private_ip" {
  description = "Application Server Private IP"
  value       = aws_instance.application_server.private_ip
}

output "observability_server_private_ip" {
  description = "Observability Server Private IP"
  value       = aws_instance.observability_server.private_ip
}

output "rds_endpoint" {
  description = "RDS endpoint address"
  value       = aws_db_instance.rds_instance.address
}

output "rds_port" {
  description = "RDS port"
  value       = aws_db_instance.rds_instance.port
}

output "jenkins_fqdn" {
  value = aws_route53_record.jenkins.fqdn
  description = "Fully qualified domain name for the Jenkins server"
}

output "observability_fqdn" {
  value = aws_route53_record.observability.fqdn
  description = "Fully qualified domain name for the Observability server"
}

output "app_fqdn" {
  value = aws_route53_record.app.fqdn
  description = "Fully qualified domain name for the Application server"
}

output "nginx_fqdn" {
  value = aws_route53_record.nginx.fqdn
  description = "Fully qualified domain name for the NGINX server"
}