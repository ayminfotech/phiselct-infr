# Public DNS Zone
data "aws_route53_zone" "public" {
  name         = "phiselect.com"
  private_zone = false
}

# Jenkins (Private IP)
resource "aws_route53_record" "jenkins" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = local.instance_domains["jenkins"]
  type    = "A"
  ttl     = 300
  records = [aws_instance.jenkins_server.private_ip]

  depends_on = [aws_instance.jenkins_server]
}

# Observability (Private IP)
resource "aws_route53_record" "observability" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = local.instance_domains["observability"]
  type    = "A"
  ttl     = 300
  records = [aws_instance.observability_server.private_ip]

  depends_on = [aws_instance.observability_server]
}

# Application (Private IP)
resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = local.instance_domains["app"]
  type    = "A"
  ttl     = 300
  records = [aws_instance.application_server.private_ip]

  depends_on = [aws_instance.application_server]
}

# NGINX (Public IP)
resource "aws_route53_record" "nginx" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = local.instance_domains["nginx"]
  type    = "A"
  ttl     = 300
  records = [aws_instance.nginx_server.private_ip]

  depends_on = [aws_instance.nginx_server]
}
resource "aws_route53_record" "ats_frontend" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "ats-frontend.phiselect.com"
  type    = "A"
  alias {
    name                   = aws_lb.app_alb.dns_name
    zone_id                = aws_lb.app_alb.zone_id
    evaluate_target_health = true
  }
}