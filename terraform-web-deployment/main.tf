terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  region = "eu-west-3"
}
resource "aws_key_pair" "my-aws-key-pair" {
  key_name   = "my-key"
  public_key = file("~/.ssh/id_ed25519.pub")
  tags = {
    Name = "to destroy"
  }
}

resource "aws_instance" "ec2-server" {
  ami           = "ami-04a92520784b93e73"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my-aws-key-pair.key_name # Associate the key pair add it to the authorized keys
  tags = {
    Name = "to destroy"
  }
  user_data = <<-EOF
                #!/bin/bash
                sudo apt update
                sudo apt install -y python3-pip git
                sudo pip3 install Flask boto3
                cd /home/ubuntu
                git clone https://github.com/RayanAAY-ops/flask-app-image-downloader.git
                cd flask-app-image-downloader
                python3 app.py
              EOF


  vpc_security_group_ids = [aws_security_group.web-sg.name]
  depends_on             = [aws_s3_bucket.s3-bucket-static-files]
}

resource "aws_s3_bucket" "s3-bucket-static-files" {
  bucket = "my-bucket-terraform-deployment-30092024"
  tags = {
    Name = "to destroy"
  }
}

resource "aws_security_group" "web-sg" {
  name = "http requests allow"
  tags = {
    Name = "to destroy"
  }
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]

  }
}

