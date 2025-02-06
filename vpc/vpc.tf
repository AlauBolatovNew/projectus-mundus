resource "aws_vpc" "k8svpc" {
  cidr_block = var.cidr

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "k8svpc-igw" {
  vpc_id = aws_vpc.k8svpc.id

  tags = {
    Name = "k8svpc-igw"
  }

  depends_on = [aws_vpc.k8svpc]
}

resource "aws_subnet" "private-us-east-2a" {
  vpc_id            = aws_vpc.k8svpc.id
  cidr_block        = "10.10.0.0/19"
  availability_zone = "us-east-2a"

  tags = {
    Name                              = "private-us-east-2a"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo"      = "owned"
  }

  depends_on = [aws_vpc.k8svpc]
}

resource "aws_subnet" "private-us-east-2b" {
  vpc_id            = aws_vpc.k8svpc.id
  cidr_block        = "10.10.32.0/19"
  availability_zone = "us-east-2b"

  tags = {
    Name                              = "private-us-east-2b"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo"      = "owned"
  }

  depends_on = [aws_vpc.k8svpc]
}

resource "aws_subnet" "public-us-east-2a" {
  vpc_id                  = aws_vpc.k8svpc.id
  cidr_block              = "10.10.64.0/19"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name                         = "public-us-east-2a"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }

  depends_on = [aws_vpc.k8svpc]
}

resource "aws_subnet" "public-us-east-2b" {
  vpc_id                  = aws_vpc.k8svpc.id
  cidr_block              = "10.10.96.0/19"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name                         = "public-us-east-2b"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }

  depends_on = [aws_vpc.k8svpc]
}

resource "aws_eip" "nat" {
  tags = {
    Name = "nat"
  }
}

resource "aws_nat_gateway" "k8s-nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-us-east-2a.id

  tags = {
    Name = "k8s-nat"
  }

  depends_on = [aws_internet_gateway.k8svpc-igw, aws_subnet.public-us-east-2a]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.k8svpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.k8s-nat.id
  }

  tags = {
    Name = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.k8svpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8svpc-igw.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "private-us-east-2a" {
  subnet_id      = aws_subnet.private-us-east-2a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-us-east-2b" {
  subnet_id      = aws_subnet.private-us-east-2b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public-us-east-2a" {
  subnet_id      = aws_subnet.public-us-east-2a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-us-east-2b" {
  subnet_id      = aws_subnet.public-us-east-2b.id
  route_table_id = aws_route_table.public.id
}
