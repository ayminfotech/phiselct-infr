data "aws_acm_certificate" "wildcard_cert" {
  domain      = "*.phiselect.com"
  statuses    = ["ISSUED"]
  most_recent = true
}