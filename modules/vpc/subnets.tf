
resource "aws_subnet" "private-us-east-2a" {
  vpc_id            = aws_vpc.k8svpc.id
  cidr_block        = "10.10.0.0/19"
  availability_zone = "us-east-2a"

  tags = {
    Name                              = "${var.environment}-private-us-east-2a"
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
    Name                              = "${var.environment}-private-us-east-2b"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo"      = "owned"
  }

  depends_on = [aws_vpc.k8svpc]
}

resource "aws_subnet" "private-us-east-2c" {
  vpc_id            = aws_vpc.k8svpc.id
  cidr_block        = "10.10.96.0/19"
  availability_zone = "us-east-2c"

  tags = {
    Name                              = "${var.environment}-private-us-east-2c"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo"      = "owned"
  }

  depends_on = [aws_vpc.k8svpc]
}

resource "aws_subnet" "public-us-east-2a" {
  vpc_id                  = aws_vpc.k8svpc.id
  cidr_block              = "10.10.128.0/19"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name                         = "${var.environment}-public-us-east-2a"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }

  depends_on = [aws_vpc.k8svpc]
}

resource "aws_subnet" "public-us-east-2b" {
  vpc_id                  = aws_vpc.k8svpc.id
  cidr_block              = "10.10.160.0/19"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name                         = "${var.environment}-public-us-east-2b"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }

  depends_on = [aws_vpc.k8svpc]
}

resource "aws_subnet" "public-us-east-2c" {
  vpc_id                  = aws_vpc.k8svpc.id
  cidr_block              = "10.10.192.0/19"
  availability_zone       = "us-east-2c"
  map_public_ip_on_launch = true

  tags = {
    Name                         = "${var.environment}-public-us-east-2c"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }

  depends_on = [aws_vpc.k8svpc]
}
