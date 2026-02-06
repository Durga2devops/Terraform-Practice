provider "aws" {
  region = "us-east-1"
}

# Dynamically fetch latest Amazon Linux 2
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Allow SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["110.235.236.78/32"] # Never use 0.0.0.0/0 in enterprise
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "example" {

  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  root_block_device {
    encrypted = true
  }

  tags = {
    Name        = "Dev-Terraform-Instance"
    Environment = "Dev"
    Owner       = "DevOps"
    Terraform   = "true"
  }
}
