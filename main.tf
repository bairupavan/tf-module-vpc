resource "aws_vpc" "vpc" {              # creating vpc
  cidr_block           = var.cidr_block # cidr block for vpc sending from tf-module env-dev/main.tfvars
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { Name = "${var.env}-vpc" }) # merging the tags
}

module "subnet" { # calling the subnet module
  source = "./subnets"

  for_each   = var.subnets              # repeating for each subnet public, app, web and db
  vpc_id     = aws_vpc.vpc.id           # vpc_id
  cidr_block = each.value["cidr_block"] # 2 cidrs for each subnets one at a time. from tf-module env-dev/main.tfvars
  azs        = each.value["azs"]        # 2 availability zones for each subnets one at a time. from tf-module env-dev/main.tfvars
  name       = each.value["name"]       # name for each availability zone from tf-module env-dev/main.tfvars
  tags       = var.tags                 # tags
  env        = var.env                  # env
}

resource "aws_internet_gateway" "igw" { # creating internet gateway
  vpc_id = aws_vpc.vpc.id               # vpc_id to attach this igw to vpc

  tags = merge(var.tags, { Name = "${var.env}-igw" }) # merging tags
}

resource "aws_eip" "elastic_ip" {                  # creating elastic ip for nat gateway to create under public subnet
  count = length(var.subnets["public"].cidr_block) # there are 2 public subnets with 2 cidrs
  vpc   = true
  tags  = merge(var.tags, { Name = "${var.env}-eip" }) # tags
}

resource "aws_nat_gateway" "example" {                            # nat gateway
  count         = length(var.subnets["public"].cidr_block)        # there are 2 public subnets with 2 cidrs
  allocation_id = aws_eip.elastic_ip[count.index].id              # there are two elastic ips one at a time
  subnet_id     = module.subnet["public"].subnet_ids[count.index] # sending only the list of public subnet ids i.e, 2

  tags = merge(var.tags, { Name = "${var.env}-ngw" }) # merge tags

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw] # will be created once igw is created successfully
}