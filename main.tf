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
  azs = each.value["azs"]
  name = each.value["name"]
  tags = var.tags
  env = var.env
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, { Name = "${var.env}-igw" })
}

resource "aws_eip" "elastic_ip" {
  count = length(var.subnets["public"].cidr_block)
  vpc = true
  tags = merge(var.tags, { Name = "${var.env}-eip" })
}

resource "aws_nat_gateway" "example" {
  count = length(var.subnets["public"].cidr_block)
  allocation_id = aws_eip.elastic_ip[count.index].id
  subnet_id     = module.subnet["public"].subnet_ids[count.index]

  tags = merge(var.tags, { Name = "${var.env}-ngw" })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}