resource "aws_subnet" "subnet" {
  count = var.cidr_block
  vpc_id     = var.vpc_id
  cidr_block = var.cidr_block[count.index]

  tags = merge(var.tags, { Name = "${var.env}-subnet-${count.index+1}" })
}