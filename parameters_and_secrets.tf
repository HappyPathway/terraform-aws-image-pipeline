
locals {
  parameters = tomap(merge({
    region             = local.vpc_config.region,
    subnets            = join(",", local.vpc_config.subnets),
    security_group_ids = join(",", local.vpc_config.security_group_ids),
    vpc_id             = local.vpc_config.vpc_id,
    source_ami         = var.source_ami,
    ami_name           = var.project_name
    shared_accounts    = join(",", var.shared_accounts),
    project_name       = var.project_name,
    instance_type      = var.instance_type
    }, var.playbook == null ? {} : {
    playbook = var.playbook
    }, var.userdata == null ? {} : {
    userdata = var.userdata
  }))
  secrets = tomap(merge(
    var.winrm_credentials == null ? {} : { winrm_credentials = var.winrm_credentials },
    var.secrets
  ))
  secret_keys = issensitive(keys(local.secrets)) ? nonsensitive(keys(local.secrets)) : keys(local.secrets)
}

resource "aws_ssm_parameter" "parameters" {
  for_each = tomap(merge(local.parameters, var.extra_parameters))
  name     = "/image-pipeline/${var.project_name}/${each.key}"
  type     = "StringList"
  value    = each.value
}

resource "aws_secretsmanager_secret" "secrets" {
  for_each = toset(local.secret_keys)
  name     = "/image-pipeline/${var.project_name}/${each.key}"
}

resource "aws_secretsmanager_secret_version" "secrets" {
  for_each      = toset(local.secret_keys)
  secret_id     = lookup(aws_secretsmanager_secret.secrets, each.key).id
  secret_string = lookup(local.secrets, each.key)
}
