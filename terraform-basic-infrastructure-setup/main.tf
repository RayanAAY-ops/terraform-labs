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


resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "to destroy"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "My Internet Gateway"
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "My Route Table"
  }
}

resource "aws_route_table_association" "my_route_table_association" {
  subnet_id      = aws_subnet.my-subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_subnet" "my-subnet" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "to destroy"
  }
}

resource "aws_security_group" "my-aws_security_group" {
  name   = "my-security-group-ICMP"
  vpc_id = aws_vpc.my-vpc.id

  ingress {
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 22 # SSH
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "to destroy"
  }
}
resource "aws_key_pair" "my-aws-key-pair" {
  key_name ="my-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}


resource "aws_instance" "my-ec2" {
  ami                    = "ami-04a92520784b93e73"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.my-subnet.id
  vpc_security_group_ids = [aws_security_group.my-aws_security_group.id]
  key_name               = aws_key_pair.my-aws-key-pair.key_name  # Associate the key pair add it to the authorized keys

  tags = {
    Name = "to destroy"
  }
}
