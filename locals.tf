locals {
  # Environment flags
  is_test = var.environment == "test"
  is_prod = var.environment == "prod"

  # Public domain base
  base_domain = "phiselect.com"

  # Fully qualified domain names for each server
  instance_domains = {
    jenkins       = "${var.environment}-jenkins.${local.base_domain}"
    observability = "${var.environment}-observability.${local.base_domain}"
    app           = "${var.environment}-app.${local.base_domain}"
    nginx         = "web-${var.environment}.${local.base_domain}"
  }

  # Subdomain shortcut for generic records like ALB
  subdomain     = local.is_test ? "test" : "prod"
  server_domain = "${local.subdomain}.${local.base_domain}"

  # RDS instance configuration
  master_db_name       = "masterdb" # Must be lowercase, 1-63 characters
  db_instance_class    = "db.t3.micro"
  db_allocated_storage = 20
}