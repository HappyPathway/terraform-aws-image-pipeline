resource "aws_ssm_parameter" "security_group_id" {
  name  = "/image-pipeline/${var.environment}/${var.project_name}/security_group_ids"
  type  = "StringList"
  value = join(",", local.vpc_config.security_group_ids)
}

resource "aws_ssm_parameter" "region" {
  name  = "/image-pipeline/${var.environment}/${var.project_name}/region"
  type  = "String"
  value = local.vpc_config.region
}

resource "aws_ssm_parameter" "subnets" {
  name  = "/image-pipeline/${var.environment}/${var.project_name}/subnets"
  type  = "StringList"
  value = join(",", local.vpc_config.subnets)
}

resource "aws_ssm_parameter" "vpc_id" {
  name  = "/image-pipeline/${var.environment}/${var.project_name}/vpc_id"
  type  = "String"
  value = local.vpc_config.vpc_id
}

resource "aws_ssm_parameter" "ssh_user" {
  name  = "/image-pipeline/${var.environment}/${var.project_name}/ssh_user"
  type  = "String"
  value = var.ssh_user
}