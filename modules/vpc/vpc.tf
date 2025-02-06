resource "aws_vpc" "k8svpc" {
  cidr_block = var.cidr

  tags = {
    Name = "${var.environment}-eks-vpc"
  }
}

resource "aws_internet_gateway" "k8svpc-igw" {
  vpc_id = aws_vpc.k8svpc.id

  tags = {
    Name = "${var.environment}-eks-igw"
  }

  depends_on = [aws_vpc.k8svpc]
}

resource "aws_eip" "nat" {
  tags = {
    Name = "${var.environment}-eks-eip"
  }
}

resource "aws_nat_gateway" "k8s-nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-us-east-2a.id

  tags = {
    Name = "${var.environment}-eks-nat"
  }

  depends_on = [aws_internet_gateway.k8svpc-igw, aws_subnet.public-us-east-2a]
}
