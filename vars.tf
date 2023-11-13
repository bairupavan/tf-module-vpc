variable "cidr_block" {}      # the main cidr block
variable "env" {}             # env
variable "tags" {}            # tags
variable "subnets" {}         # subnet list from tf-module env-dev/main.tfvars
variable "default_vpc_id" {}
variable "default_vpc_route_id" {}
variable "default_vpc_cidr" {}