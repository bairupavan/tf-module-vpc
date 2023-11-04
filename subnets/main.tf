resource "aws_subnet" "subnet" {                  # creating the resource subnet
  count             = length(var.cidr_block)      # there are 2 cidr_blocks for each subnet so 2 subnets created for each server types
  vpc_id            = var.vpc_id                  # sending the vpc_id to create subnet under that vpc
  cidr_block        = var.cidr_block[count.index] # for each server type like app, db 2 subnets created with 2 cidr blocks
  availability_zone = var.azs[count.index]        # for each server type like app, db 2 subnets created with 2 availability zone

  tags = merge(var.tags, { Name = "${var.env}-${var.name}-subnet-${count.index + 1}" }) # merging the tags
}