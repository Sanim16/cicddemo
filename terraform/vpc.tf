resource "aws_vpc" "cicddemo" {
  cidr_block           = var.VPC_CIDR
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.PROJECT_NAME}-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.cicddemo.id

  tags = {
    Name = "${var.PROJECT_NAME}-igw"
  }
}

resource "aws_route_table" "rt-1" {
  vpc_id = aws_vpc.cicddemo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.PROJECT_NAME}-rt-1"
  }
}

resource "aws_route_table_association" "rt-1a" {
  subnet_id      = aws_subnet.public-subnet-01.id
  route_table_id = aws_route_table.rt-1.id
}

resource "aws_subnet" "public-subnet-01" {
  vpc_id                  = aws_vpc.cicddemo.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "${var.PROJECT_NAME}-public-subnet-01"
  }
}