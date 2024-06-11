resource "aws_ssm_parameter" "security_group_id" {
  name  = "/image-pipeline/${var.environment}/${var.project_name}/security_group_ids"
  type  = "StringList"
  value = join(",", var.vpc_config.security_group_ids)
}

resource "aws_ssm_parameter" "subnets" {
  name  = "/image-pipeline/${var.environment}/${var.project_name}/subnets"
  type  = "StringList"
  value = join(",", var.vpc_config.subnets)
}

resource "aws_ssm_parameter" "vpc_id" {
  name  = "/image-pipeline/${var.environment}/${var.project_name}/vpc_id"
  type  = "String"
  value = var.vpc_config.vpc_id
}