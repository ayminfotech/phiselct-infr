###############################
# Data Sources for AMIs
###############################
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

###############################
# Bastion Host (Public Subnet)
###############################
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = var.key_name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "phi-select-${var.environment}-bastion"
  }
}

###############################
# Common Docker Installation Script
###############################
locals {
  docker_install_script = <<-EOF
    #!/bin/bash
    set -eux

    curl -fsSL https://get.docker.com | sh

    apt-get update -y
    apt-get install -y git tree jq

    systemctl enable docker
    systemctl start docker

    usermod -aG docker ubuntu
  EOF
}

###############################
# Jenkins Server (Private Subnet)
###############################
resource "aws_instance" "jenkins_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.large"
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.micro_sg.id, aws_security_group.bastion_sg.id]
  key_name               = var.key_name

  user_data = <<-EOF
    ${local.docker_install_script}

    mkdir -p /home/ubuntu/jenkins
    chown -R ubuntu:ubuntu /home/ubuntu/jenkins

    docker run -d --restart unless-stopped \
      --name jenkins \
      -p 8080:8080 \
      -p 50000:50000 \
      -v /home/ubuntu/jenkins:/var/jenkins_home \
      -v /var/run/docker.sock:/var/run/docker.sock \
      jenkins/jenkins:lts-jdk17
  EOF

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  tags = {
    Name = "phi-select-${var.environment}-jenkins-server"
  }
}

###############################
# Nginx Server (Public Subnet)
###############################
resource "aws_instance" "nginx_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.public[1].id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  key_name               = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    set -eux

    yum update -y
    amazon-linux-extras install docker -y
    systemctl enable --now docker
    usermod -aG docker ec2-user

    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
      -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
  EOF

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "phi-select-${var.environment}-nginx-server"
  }
}

###############################
# Application Server (Private Subnet)
###############################
resource "aws_instance" "application_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.large"
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.app_server_sg.id, aws_security_group.bastion_sg.id]
  key_name               = var.key_name

  user_data = local.docker_install_script

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "phi-select-${var.environment}-application-server"
  }
}

###############################
# Observability Server (Private Subnet)
###############################
resource "aws_instance" "observability_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.private[1].id
  vpc_security_group_ids = [aws_security_group.observability_sg.id]
  key_name               = var.key_name

  user_data = local.docker_install_script

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "phi-select-${var.environment}-observability-server"
  }
}
