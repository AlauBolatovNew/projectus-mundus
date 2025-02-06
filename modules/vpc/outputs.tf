output "private_subnet_1_id" {
  value = aws_subnet.private-us-east-2a.id
}

output "private_subnet_2_id" {
  value = aws_subnet.private-us-east-2b.id
}

output "private_subnet_3_id" {
  value = aws_subnet.private-us-east-2c.id
}

output "public_subnet_1_id" {
  value = aws_subnet.public-us-east-2a.id
}

output "public_subnet_2_id" {
  value = aws_subnet.public-us-east-2b.id
}

output "public_subnet_3_id" {
  value = aws_subnet.public-us-east-2c.id
}

output "vpc_id" {
  value = aws_vpc.k8svpc.id
}