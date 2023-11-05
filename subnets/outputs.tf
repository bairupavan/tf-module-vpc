output "subnet_ids" {       # sending all the subnet_ids for nat gateway
  value = aws_subnet.subnet.*.id
}

output "route_table_ids" {
  value = aws_route_table.rt.*.id
}

output "route_table" {
  value = aws_route_table.rt   # extracting the two route tables
}