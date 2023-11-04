variable "vpc_id" {}        # vpc_id from vpc resource
variable "cidr_block" {}    # the main vpc cidr_block
variable "tags" {}          # tags
variable "env" {}           # env
variable "name" {}          # name for each subnet
variable "azs" {}           # availability zone for each subnet