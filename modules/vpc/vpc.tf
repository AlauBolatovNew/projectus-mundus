resource "aws_vpc" "vpc_centos" {
  cidr_block = var.cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_subnet" "public" {
  count = 3
  vpc_id = aws_vpc.vpc_centos.id
  cidr_block = element(var.public_subnet_cidr_blocks, count.index)
  availability_zone = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count = 3
  vpc_id = aws_vpc.vpc_centos.id
  cidr_block = element(var.private_subnet_cidr_blocks, count.index)
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = "${var.environment}-private-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "vpc_centos" {
  vpc_id = aws_vpc.vpc_centos.id
  tags = {
    Name = "${var.environment}-igw"
  }
}

resource "aws_security_group" "eks_sg" {
  vpc_id = aws_vpc.vpc_centos.id
  name        = "${var.environment}-eks-sg"
  description = "EKS Security Group"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
  }
}