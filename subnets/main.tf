resource "aws_subnet" "subnet" {                  # creating the resource subnet
  count             = length(var.cidr_block)      # there are 2 cidr_blocks for each subnet so 2 subnets created for each server types
  vpc_id            = var.vpc_id                  # sending the vpc_id to create subnet under that vpc
  cidr_block        = var.cidr_block[count.index] # for each server type like app, db 2 subnets created with 2 cidr blocks
  availability_zone = var.azs[count.index]        # for each server type like app, db 2 subnets created with 2 availability zone

  tags = merge(var.tags, { Name = "${var.env}-${var.name}-subnet-${count.index + 1}" }) # merging the tags
}

resource "aws_route_table" "rt" {
  count  = length(var.cidr_block) # there are 2 cidr_blocks for each route so 2 routes created foreach server types
  vpc_id = var.vpc_id             # sending the vpc_id to create route under that vpc
}

resource "aws_route_table_association" "rt_association" {
  count          = length(var.cidr_block) # there are 2 cidr_blocks for each subnet so 2 subnets created for each server types
  subnet_id      = aws_subnet.subnet[count.index].id  # finding the each subnet id
  route_table_id = aws_route_table.rt[count.index].id  # and then adding the each route table to each subnet_id
}