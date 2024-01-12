output "region" {
  value = var.region
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnets_ids" {
 value = (aws_subnet.public_subnet[*].id)
}

output "private_subnets_ids" {
 value = (aws_subnet.private_subnet[*].id)
}