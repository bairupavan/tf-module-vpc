output "subnet_ids" {       # sending all the subnet_ids for nat gateway
  value = aws_subnet.subnet.*.id
}