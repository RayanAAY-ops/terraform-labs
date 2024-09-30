
Mémoire mise à jour
Here are some hands-on lab projects you can try to practice Terraform as a beginner:

1. Basic Infrastructure Setup
# Objective: Create a simple infrastructure in AWS using Terraform.
## Components:
- VPC
- Public and private subnets
- EC2 instance in the public subnet
- Security group for allowing SSH access to the EC2 instance
## Steps:
- Write Terraform configurations to define the VPC, subnets, and EC2 instance.
- Use the terraform init command to initialize your project.
- Run terraform plan to see what will be created.
- Execute terraform apply to create the infrastructure.
- Test by SSHing into the EC2 instance.
### 1. **Setting Up Your Infrastructure with Terraform**

#### Terraform Configuration Basics
- **Provider Declaration**: Begin by specifying the AWS provider in your Terraform configuration.
  ```hcl
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
  ```

#### VPC (Virtual Private Cloud)
- **Creating a VPC**: Create a VPC to isolate your resources.
  ```hcl
  resource "aws_vpc" "my-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "to destroy"
    }
  }
  ```

#### Subnet
- **Creating a Subnet**: Create a subnet within your VPC and set it as a public subnet by enabling `map_public_ip_on_launch`.
  ```hcl
  resource "aws_subnet" "my-subnet" {
    vpc_id                  = aws_vpc.my-vpc.id
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = true
    tags = {
      Name = "to destroy"
    }
  }
  ```

#### Internet Gateway
- **Creating an Internet Gateway**: To allow public internet access, create an Internet Gateway and attach it to your VPC.
  ```hcl
  resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my-vpc.id
    tags = {
      Name = "My Internet Gateway"
    }
  }
  ```

#### Route Table
- **Creating a Route Table**: Set up a route table that directs internet traffic (0.0.0.0/0) to the Internet Gateway.
  ```hcl
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
  ```

- **Associating the Route Table with the Subnet**:
  ```hcl
  resource "aws_route_table_association" "my_route_table_association" {
    subnet_id      = aws_subnet.my-subnet.id
    route_table_id = aws_route_table.my_route_table.id
  }
  ```

#### Security Group
- **Creating a Security Group**: Create a security group to control inbound and outbound traffic. Include rules for ICMP (ping) and SSH.
  ```hcl
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
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      cidr_blocks = ["YOUR_PUBLIC_IP/32"]  # Replace with your public IP for SSH
    }

    tags = {
      Name = "to destroy"
    }
  }
  ```

#### EC2 Instance
- **Creating an EC2 Instance**: Launch an EC2 instance within the public subnet and associate the created security group.
  ```hcl
  resource "aws_key_pair" "my_key" {
    key_name   = "my-key"
    public_key = file("~/.ssh/my-key.pub")
  }

  resource "aws_instance" "my-ec2" {
    ami                    = "ami-04a92520784b93e73"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.my-subnet.id
    vpc_security_group_ids = [aws_security_group.my-aws_security_group.id]
    key_name               = aws_key_pair.my_key.key_name  # Associate the key pair
    tags = {
      Name = "to destroy"
    }
  }
  ```

### 2. **Applying Your Terraform Configuration**
- **Initialize and Apply**: Run the following commands to apply your configuration:
  ```bash
  terraform init
  terraform apply
  ```

### 3. **SSH Access**
- **Using SSH**: Use your private key to connect to your EC2 instance:
  ```bash
  ssh -i ~/.ssh/my-key ubuntu@<public-ip>
  ```

### Summary of Key Concepts
- **VPC**: A private network in AWS where you can define your own IP address range, subnets, and security settings.
- **Subnets**: Logical subdivisions within a VPC; a public subnet allows direct access to the internet.
- **Internet Gateway**: Allows communication between instances in your VPC and the internet.
- **Route Table**: Defines the routes for outbound traffic, directing it to the Internet Gateway for internet access.
- **Security Groups**: Acts as a virtual firewall for your instances to control inbound and outbound traffic.
- **SSH Key Pairs**: Used for secure access to your EC2 instances.

This summary encapsulates the entire process of setting up a simple cloud infrastructure using Terraform on AWS, from creating a VPC to launching an EC2 instance with SSH access. If you have any further questions or need additional details on any part, feel free to ask!