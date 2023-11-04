resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = merge(var.tags, { Name = "${var.env}-vpc" })
}

module "subnet" {
  source = "./subnets"

  for_each = var.subnets
  vpc_id = aws_vpc.vpc.id
  cidr_block = each.value["cidr_block"]
  name = each.value["name"]
  tags = var.tags
  env = var.env
}