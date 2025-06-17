##########################################
# RDS PostgreSQL – Single Instance (Master DB Only)
##########################################
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "phi-select-${var.environment}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id
  tags = {
    Name        = "phi-select-${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

resource "aws_db_instance" "rds_instance" {
  identifier              = "phi-select-${var.environment}-rds"
  engine                  = "postgres"
  engine_version          = "13.20"
  instance_class          = local.db_instance_class
  allocated_storage       = local.db_allocated_storage
  db_name                 = local.master_db_name
  username                = "phiadmin"
  password                = "Phiadmin123"
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  tags = {
    Name        = "phi-select-${var.environment}-rds"
    Environment = var.environment
  }
}