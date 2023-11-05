locals {
  all_private_subnet_cidrs = concat(module.subnet["app"].route_table_ids, module.subnet["web"].route_table_ids,
    module.subnet["db"].route_table_ids)
}
