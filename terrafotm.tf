provider "aws" {
  region = var.aws_region
}

# Security group for Jenkins
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Security group for Jenkins servers"

  # Jenkins web interface
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # Agent communication
  ingress {
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-security-group"
  }
}

# EC2 instance for Jenkins
resource "aws_instance" "jenkins_master" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  subnet_id              = var.subnet_id

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = false
  }

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io docker-compose-plugin
    systemctl enable docker
    systemctl start docker
    usermod -aG docker ubuntu
    mkdir -p /opt/jenkins
    chown -R ubuntu:ubuntu /opt/jenkins

    # Download docker-compose.yml
    curl -o /opt/jenkins/docker-compose.yml https://raw.githubusercontent.com/yourusername/jenkins-infrastructure/main/docker-compose.yml
    
    # Set up environment variables
    cat > /opt/jenkins/.env << 'ENVFILE'
    JENKINS_ADMIN_ID=admin
    JENKINS_ADMIN_PASSWORD=${var.jenkins_admin_password}
    GITHUB_SSH_PRIVATE_KEY=${var.github_ssh_private_key}
    ENVFILE

    # Start Jenkins
    cd /opt/jenkins
    docker compose up -d
  EOF

  tags = {
    Name = "jenkins-master"
  }
}

# Variables
variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-west-2"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance (Ubuntu 22.04 LTS recommended)"
  # Use a proper AMI that is regularly patched
  default     = "ami-03f65b8614a860c29" # Ubuntu 22.04 in us-west-2
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.medium"
}

variable "key_pair_name" {
  description = "Name of the key pair to use for SSH access"
}

variable "subnet_id" {
  description = "Subnet ID where EC2 instance will be launched"
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access Jenkins"
  default     = ["0.0.0.0/0"]  # Consider restricting this in production
}

variable "jenkins_admin_password" {
  description = "Jenkins admin password"
  sensitive   = true
}

variable "github_ssh_private_key" {
  description = "GitHub SSH private key for Jenkins"
  sensitive   = true
}

# Outputs
output "jenkins_public_ip" {
  value = aws_instance.jenkins_master.public_ip
}

output "jenkins_url" {
  value = "http://${aws_instance.jenkins_master.public_ip}:8080"
}