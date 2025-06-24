#############################################
# Security Group for RDS (DB)
#############################################
resource "aws_security_group" "db_sg" {
  name        = "phi-select-${var.environment}-db-sg"
  description = "Allow PostgreSQL access from microservices"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.micro_sg.id, aws_security_group.bastion_sg.id]
    description     = "Allow PostgreSQL access from microservices"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "phi-select-${var.environment}-db-sg"
    Environment = var.environment
  }
}

#############################################
# Bastion Host Security Group
#############################################
resource "aws_security_group" "bastion_sg" {
  name        = "phi-select-${var.environment}-bastion-sg"
  description = "Allow SSH from allowed public IP"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
    description = "Allow SSH access from allowed IP"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "phi-select-${var.environment}-bastion-sg"
    Environment = var.environment
  }
}

#############################################
# Microservices (Jenkins) Security Group
#############################################
resource "aws_security_group" "micro_sg" {
  name        = "phi-select-${var.environment}-micro-sg"
  description = "Allow communication for microservices and Jenkins"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow SSH access within VPC"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow traffic on port 8080 within VPC"
  }

  ingress {
    from_port   = 8580
    to_port     = 8580
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow traffic on port 8580 within VPC"
  }
  
   ingress {
    from_port   = 8290
    to_port     = 8290
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow traffic on port 8580 within VPC"
  }
   ingress {
    from_port   = 8380
    to_port     = 8380
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow traffic on port 8580 within VPC"
  }
  

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow traffic on port 3000 within VPC"
  }

  ingress {
    from_port   = 9411
    to_port     = 9411
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow traffic on port 9411 within VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "phi-select-${var.environment}-micro-sg"
    Environment = var.environment
  }
}

#############################################
# Nginx Security Group
#############################################
resource "aws_security_group" "nginx_sg" {
  name        = "phi-select-${var.environment}-nginx-sg"
  description = "Allow HTTP/HTTPS traffic from the public network"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow SSH within VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "phi-select-${var.environment}-nginx-sg"
    Environment = var.environment
  }
}

#############################################
# Application Server Security Group
#############################################
resource "aws_security_group" "app_server_sg" {
  name        = "phi-select-${var.environment}-app-server-sg"
  description = "Allow internal communication for the Application Server"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow SSH access within VPC"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow traffic on port 8080"
  }

  ingress {
    from_port   = 8580
    to_port     = 8580
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow traffic on port 8580"
  }
  ingress {
    from_port   = 8761
    to_port     = 8761
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow traffic on port 8580"
  }

  ingress {
    from_port   = 8290
    to_port     = 8290
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow traffic on port 8580"
  }
  ingress {
    from_port   = 8380
    to_port     = 8380
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow traffic on port 8580"
  }

  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow traffic on port 8580"
  }
  ingress {
    from_port   = 8280
    to_port     = 8280
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow traffic on port 8580"
  }
  ingress {
    from_port   = 8384
    to_port     = 8384
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow traffic on port 8580"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "phi-select-${var.environment}-app-server-sg"
    Environment = var.environment
  }
}

#############################################
# Observability Security Group
#############################################
resource "aws_security_group" "observability_sg" {
  name        = "phi-select-${var.environment}-observability-sg"
  description = "Allow internal communication for observability services (Loki, Grafana, etc.)"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow observability service traffic within VPC"
  }
  ingress {
    from_port   = 3100
    to_port     = 3100
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow observability service traffic within VPC"
  }
  ingress {
    from_port   = 9411
    to_port     = 9411
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow observability service traffic within VPC"
  }
  ingress {
    from_port   = 8761
    to_port     = 8761
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow observability service traffic within VPC"
  }
   ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow SSH access within VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "phi-select-${var.environment}-observability-sg"
    Environment = var.environment
  }
}

#############################################
# ALB Security Group
#############################################
resource "aws_security_group" "alb_sg" {
  name        = "phi-select-${var.environment}-alb-sg"
  vpc_id      = aws_vpc.main.id
  description = "Security group for the ALB"

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "phi-select-${var.environment}-alb-sg"
    Environment = var.environment
  }
}