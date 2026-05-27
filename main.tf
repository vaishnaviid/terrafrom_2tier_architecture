# Configure the AWS Backend for Terraform state storage
terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket-3457"
    key    = "terraform.tfstate"
    region    = "us-west-2"
  } 
}

# Configure the AWS provider
provider "aws" {
    region = var.region
}

# Create a VPC with the specified CIDR block and name
resource "aws_vpc" "my_vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = var.vpc_name
    }
}

# create private subnet in the VPC
resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = var.pvt_subnet_cidr
    availability_zone = var.availability_zone1
    tags = {
        Name = "$(var.vpc_name)-private-subnet"
    }
}

# create public subnet in the VPC
resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = var.public_subnet_cidr
    availability_zone = var.availability_zone2  
    map_public_ip_on_launch = true  # Automatically assign public IPs to instances launched in this subnet
    tags = {
        Name = "$(var.vpc_name)-public-subnet"
    }
}

# create an internet gateway and attach it to the VPC
resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
        Name = "$(var.vpc_name)-igw"
    }
}

# create a default route table for the public subnet and associate it with the internet gateway
resource "aws_default_route_table" "main_route_table" {
    default_route_table_id = aws_vpc.my_vpc.default_route_table_id
    tags = {
        Name = "$(var.vpc_name)-main-route-table"
    }
}

# default route to the internet gateway for all traffic
resource "aws_route" "default_route" {
    route_table_id = aws_default_route_table.main_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
}

# create a security group
resource "aws_security_group" "web_sg" {
    name = "${var.vpc_name}-sg"
    description = "Allow HTTP, MySQL and SSH traffic"
    vpc_id = aws_vpc.my_vpc.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    depends_on = [aws_vpc.my_vpc]
}

# create an EC2 instance in the public subnet
resource "aws_instance" "public_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  tags = {
    Name = "${var.vpc_name}-public-instance"
  }
}

# create an EC2 instance in the private subnet
resource "aws_instance" "private_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  tags = {
    Name = "${var.vpc_name}-private-instance"
  }
}