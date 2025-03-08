locals {
  # Domain based on environment: test or prod
  is_test       = var.environment == "test"
  is_prod       = var.environment == "prod"
  subdomain     = local.is_test ? "test" : "prod"
  server_domain = "${local.subdomain}.phiselect.com"
  # RDS instance configuration values
  master_db_name           = "masterdb"           # Must be lowercase, 1-63 characters
  db_instance_class        = "db.t3.micro"
  db_allocated_storage     = 20
}