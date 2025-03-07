resource "aws_route53_record" "server_domain" {
  zone_id = var.route53_zone_id
  name    = local.server_domain
  type    = "A"
  ttl     = 300
  records = [aws_instance.nginx_server.public_ip]
}