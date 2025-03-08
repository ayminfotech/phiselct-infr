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
    # Allow traffic from the microservices security group only.
    security_groups = [aws_security_group.micro_sg.id,aws_security_group.bastion_sg.id]
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
    # Replace var.allowed_ssh_cidr with your public IP (or CIDR) allowed for SSH
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
# Microservices Security Group
#############################################
resource "aws_security_group" "micro_sg" {
  name        = "phi-select-${var.environment}-micro-sg"
  description = "Allow communication for Java microservices and GitHub Runner within the private network"
  vpc_id      = aws_vpc.main.id

  # Allow SSH (port 22) from anywhere within the VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow SSH access from the private network"
  }

  # Allow microservices traffic on port 8080 from within the VPC
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow microservices communication on port 8080 from the private network"
  }

  # Allow microservices traffic on port 8081 from within the VPC
  ingress {
    from_port   = 8580
    to_port     = 8580
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow microservices communication on port 8081 from the private network"
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
# Security Group for Nginx Public Server
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
    description = "Allow HTTP traffic from the public internet"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic from the public internet"
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
resource "aws_instance" "application_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.app_server_sg.id, aws_security_group.bastion_sg.id]
  key_name               = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get upgrade -y
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu

    # Optionally install docker-compose if required by your deployment scripts
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    # No container deployments here.
    # Deployment scripts triggered by GitHub Runner will handle container orchestration.
  EOF

  tags = {
    Name        = "phi-select-${var.environment}-application-server"
    Environment = var.environment
  }
}