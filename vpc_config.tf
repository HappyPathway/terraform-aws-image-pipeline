# Full Expression Breakdown
#   Condition: var.vpc_config == null || !var.create_vpc_endpoint
#   If var.vpc_config is null or var.create_vpc_endpoint is false
#   Result: toset([]) (an empty set)
#   Otherwise
#   Result: toset(var.vpc_services) (a set containing the values of var.vpc_services)
#   Usage
#   This expression is typically used to conditionally set a variable or an argument in a resource or module based on the configuration provided. 
#   It ensures that if certain conditions are not met, an empty set is used instead of the actual values from var.vpc_services.

#   Example
#   If var.vpc_config is null and var.create_vpc_endpoint is true:
#   The expression evaluates to toset([]).

#   If var.vpc_config is not null and var.create_vpc_endpoint is true:
#   The expression evaluates to toset(var.vpc_services).
resource "aws_vpc_endpoint" "endpoint" {
  for_each          = var.vpc_config == null || !var.create_vpc_endpoint ? toset([]) : toset(var.vpc_services) # see above...
  vpc_id            = local.vpc_config.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_endpoint_type = "Interface"

  security_group_ids = local.vpc_config.security_group_ids
  subnet_ids         = local.vpc_config.subnets
}
