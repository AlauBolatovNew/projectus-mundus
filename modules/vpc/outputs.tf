output "vpc_id" {
  value = aws_vpc.vpc_centos.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}
output "eks_sg" {
  value = aws_security_group.eks_sg.id
}