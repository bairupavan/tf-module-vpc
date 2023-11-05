locals {
all_private_subnet_cidrs = concat(var.subnets["app"].route_table_ids, var.subnets["web"].route_table_ids,var.subnets["db"]
.route_table_ids)
}