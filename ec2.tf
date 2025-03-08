data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}
# Data source for Ubuntu 22.04 (for microservices)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical's owner ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
# Bastion Host (Public Subnet)
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "phi-select-${var.environment}-bastion"
  }
}

# Microservices (Private Subnet) - Ubuntu 22.04
resource "aws_instance" "microservices" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.micro_sg.id,aws_security_group.bastion_sg.id]
  key_name               = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    # Update system packages
    apt-get update -y
    apt-get upgrade -y

    # Install Docker
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu

    # Install docker-compose (optional)
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    # Create folder for GitHub Runner and configure it
    cd /home/ubuntu
    mkdir -p actions-runner && cd actions-runner
    curl -o actions-runner-linux-x64-2.322.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.322.0/actions-runner-linux-x64-2.322.0.tar.gz
    # Optional: Validate the hash (if needed)
    # echo "b13b784808359f31bc79b08a191f5f83757852957dd8fe3dbfcc38202ccf5768  actions-runner-linux-x64-2.322.0.tar.gz" | shasum -a 256 -c
    tar xzf actions-runner-linux-x64-2.322.0.tar.gz
    ./config.sh --url https://github.com/aymsudha/ats-registration-service --token BFAJCMY7MLUBGJLFSBJZT6THYWZTQ --unattended --replace
    nohup ./run.sh > /home/ubuntu/runner.log 2>&1 &
  EOF

  tags = {
    Name = "phi-select-${var.environment}-microservices"
  }
}

# Nginx Server on Public Subnet (Target EC2)
# This server installs and runs Nginx and will be accessible via Route53.
resource "aws_instance" "nginx_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.environment == "prod" ? "m5.large" : "t3.micro"
  subnet_id              = aws_subnet.public[1].id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  key_name               = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install nginx1 -y
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>Welcome to ${local.server_domain}</h1>" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "phi-select-${var.environment}-nginx-server"
  }
}
resource "aws_security_group" "app_server_sg" {
  name        = "phi-select-${var.environment}-app-server-sg"
  description = "Allow internal communication for the Application Server within the private network"
  vpc_id      = aws_vpc.main.id

  # Allow SSH (port 22) from anywhere within the VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow SSH access within VPC"
  }

  # Allow traffic on port 8080 from anywhere within the VPC
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow traffic on port 8080 within VPC"
  }

  # Allow traffic on port 8580 from anywhere within the VPC
  ingress {
    from_port   = 8580
    to_port     = 8580
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow traffic on port 8580 within VPC"
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