resource "aws_vpc" "vpc" {              # creating vpc
  cidr_block           = var.cidr_block # cidr block for vpc sending from tf-module env-dev/main.tfvars
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { Name = "${var.env}-vpc" }) # merging the tags
}

module "subnets" { # calling the subnet module
  source = "./subnets"

  for_each   = var.subnets              # repeating for each subnet public, app, web and db
  vpc_id     = aws_vpc.vpc.id           # vpc_id
  cidr_block = each.value["cidr_block"] # 2 cidrs for each subnets one at a time. from tf-module env-dev/main.tfvars
  azs        = each.value["azs"]        # 2 availability zones for each subnets one at a time. from tf-module env-dev/main.tfvars
  name       = each.value["name"]       # name for each availability zone from tf-module env-dev/main.tfvars
  tags       = var.tags                 # tags
  env        = var.env                  # env
}

# creating internet gateway to all traffic
resource "aws_internet_gateway" "igw" { # creating internet gateway
  vpc_id = aws_vpc.vpc.id               # vpc_id to attach this igw to vpc

  tags = merge(var.tags, { Name = "${var.env}-igw" }) # merging tags
}

# attaching internet gateway to public subnets to all the traffic
resource "aws_route" "public_route_igw" {
  count                  = length(module.subnets["public"].route_table_ids)                 # there are 2 public subnets with 2 routes tables
  route_table_id         = module.subnets["public"].route_table_ids[count.index]            # sending only the list of public route ids i.e, 2 routes
  gateway_id             = aws_internet_gateway.igw.id                                      # attaching this route to internet gateway
  destination_cidr_block = "0.0.0.0/0"                                                      # internet connetion to all address
  depends_on             = [module.subnets["public"].route_table, aws_internet_gateway.igw] # create based on public route tables and igw created successfully
}

# creating elastic ip to attach it to nat gateway
resource "aws_eip" "elastic_ip" {                  # creating elastic ip for nat gateway to create under public subnet
  count = length(var.subnets["public"].cidr_block) # there are 2 public subnets with 2 cidrs
  vpc   = true
  tags  = merge(var.tags, { Name = "${var.env}-eip" }) # tags
}

# creating the nat gateway in the public subnets to allow the private subnets instances through this
resource "aws_nat_gateway" "nat_gateway" {                         # nat gateway
  count         = length(var.subnets["public"].cidr_block)         # there are 2 public subnets with 2 cidrs
  allocation_id = aws_eip.elastic_ip[count.index].id               # there are two elastic ips one at a time
  subnet_id     = module.subnets["public"].subnet_ids[count.index] # sending only the list of public subnet ids i.e, 2

  tags = merge(var.tags, { Name = "${var.env}-ngw" }) # merge tags

  depends_on = [module.subnets["public"].subnet_ids] # will be created once public subnets is created successfully
}

# attaching the nat gateway to the private subnets
resource "aws_route" "private_routes_ngw" {                                                                                                                      # nat gateway
  count                  = length(local.all_private_subnet_cidrs)                                                                                                # all private subnet_id routes i.e, 6
  route_table_id         = local.all_private_subnet_cidrs[count.index]                                                                                           # sending only the list of private subnet id routes i.e, 6 app, web and db
  nat_gateway_id         = element(aws_nat_gateway.nat_gateway.*.id, count.index)                                                                                # attaching routes of same private subnet to two diff nat gates
  destination_cidr_block = "0.0.0.0/0"                                                                                                                           # internet connetion to all address
  depends_on             = [module.subnets["app"].route_table, module.subnets["web"].route_table, module.subnets["db"].route_table, aws_nat_gateway.nat_gateway] #will be created once app, db and route tables and nat gateways are created successfully
}
