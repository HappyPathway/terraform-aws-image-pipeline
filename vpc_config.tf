resource "aws_vpc_endpoint" "codecommit" { 
  for_each = var.vpc_config == null ? toset([]) : toset([
    "codecommit",
    "git-codecommit"
  ])
  vpc_id       = local.vpc_config.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_endpoint_type = "Interface"
  
  security_group_ids = local.vpc_config.security_group_ids
  subnet_ids = local.vpc_config.subnets
}
