data "aws_route53_zone" "existing_zone" {
  name         = "phiselect.com"
  private_zone = false
}

resource "aws_route53_record" "test_record" {
  count   = local.is_test ? 1 : 0
  zone_id = data.aws_route53_zone.existing_zone.zone_id
  name    = local.server_domain  # e.g., "test" so it becomes test.phiselect.com
  type    = "A"
  alias {
    name                   = aws_lb.app_alb.dns_name
    zone_id                = aws_lb.app_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "prod_record" {
  count   = local.is_prod ? 1 : 0
  zone_id = data.aws_route53_zone.existing_zone.zone_id
  name    = local.server_domain  # e.g., "prod" so it becomes prod.phiselect.com
  type    = "A"
  alias {
    name                   = aws_lb.app_alb.dns_name
    zone_id                = aws_lb.app_alb.zone_id
    evaluate_target_health = true
  }
}