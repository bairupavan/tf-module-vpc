# getting all the subnet details
output "subnets" {
  value = module.subnets
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}