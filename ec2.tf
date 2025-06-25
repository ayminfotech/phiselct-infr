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
  user_data = local.docker_install_script
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
#!/bin/bash
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
set -eux

echo "[INFO] Installing prerequisites"
apt-get update -y
apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release

echo "[INFO] Installing Docker"
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "[INFO] Starting Docker"
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

echo "[INFO] Creating Jenkins volume"
docker volume create jenkins_data

echo "[INFO] Creating Groovy init script for admin user"
mkdir -p /var/jenkins_home/init.groovy.d

cat <<EOG > /var/jenkins_home/init.groovy.d/basic-security.groovy
#!groovy
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", "admin123")
instance.setSecurityRealm(hudsonRealm)
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)
instance.save()
EOG

chown -R 1000:1000 /var/jenkins_home

echo "[INFO] Running Jenkins container"
docker run -d \
  --name jenkins \
  --restart=unless-stopped \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_data:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/jenkins_home/init.groovy.d:/var/jenkins_home/init.groovy.d \
  -u root \
  jenkins/jenkins:lts
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

  user_data = local.docker_install_script

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