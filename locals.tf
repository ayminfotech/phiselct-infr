locals {
  # Domain based on environment: test or prod
  server_domain = var.environment == "prod" ? "prod.phiselect.com" : "test.phiselect"
  
  # RDS instance configuration values
  master_db_name           = "masterdb"           # Must be lowercase, 1-63 characters
  db_instance_class        = "db.t3.micro"
  db_allocated_storage     = 20
}