variable "region" {
    default = "us-west-2"
}

# vpc variables
variable "vpc_cidr_block" {
    default = "10.0.0.0/16"
}
variable "vpc_name" {
    default = "2tier_vpc"
}

# private subnet variables
variable "availability_zone1" {
    default = "us-west-2a"
}
variable "pvt_subnet_cidr" {
    default = "10.0.0.0/20"
}

# public subnet variables
variable "availability_zone2" {
    default = "us-west-2b"
}
variable "public_subnet_cidr" {
    default = "10.0.0.16/20"
}

# ec2 instance variables
variable "instance_type" {
    default = "t2.micro"
}
variable "ami" {
    default = "ami-0c94855ba95c71c99"
}
variable "key_name" {
    default = "2tierkey"
}
