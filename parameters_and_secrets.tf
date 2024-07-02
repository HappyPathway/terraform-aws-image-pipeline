resource "aws_ssm_parameter" "security_group_id" {
  name  = "/image-pipeline/${var.project_name}/security_group_ids"
  type  = "StringList"
  value = join(",", local.vpc_config.security_group_ids)
}

resource "aws_ssm_parameter" "region" {
  name  = "/image-pipeline/${var.project_name}/region"
  type  = "String"
  value = local.vpc_config.region
}

resource "aws_ssm_parameter" "subnets" {
  name  = "/image-pipeline/${var.project_name}/subnets"
  type  = "StringList"
  value = join(",", local.vpc_config.subnets)
}

resource "aws_ssm_parameter" "vpc_id" {
  name  = "/image-pipeline/${var.project_name}/vpc_id"
  type  = "String"
  value = local.vpc_config.vpc_id
}

resource "aws_ssm_parameter" "ssh_user" {
  name  = "/image-pipeline/${var.project_name}/ssh_user"
  type  = "String"
  value = var.ssh_user
}

resource "aws_ssm_parameter" "goss_profile" {
  name  = "/image-pipeline/${var.project_name}/goss_profile"
  type  = "String"
  value = var.goss_profile
}

resource "aws_ssm_parameter" "extra_parameters" {
  for_each = var.extra_parameters
  name     = "/image-pipeline/${var.project_name}/${each.key}"
  type     = "String"
  value    = each.value
}

resource "aws_secretsmanager_secret" "secrets" {
  for_each = var.secrets
  name     = "/image-pipeline/${var.project_name}/${each.key}"
}

resource "aws_secretsmanager_secret_version" "secrets" {
  for_each      = var.secrets
  secret_id     = lookup(aws_secretsmanager_secret.secrets, each.key).id
  secret_string = each.value
}
