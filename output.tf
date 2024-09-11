output "vpc_id" {
  value = aws_vpc.jfrog_vpc.id
}

output "public_subnet_1_id" {
  value = aws_subnet.jfrog_pub_subnet_1.id
}
output "private_subnet_1_id" {
  value = aws_subnet.jfrog_priv_subnet_1.id
}
