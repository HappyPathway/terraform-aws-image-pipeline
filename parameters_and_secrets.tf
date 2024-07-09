
locals {
  parameters = tomap(merge({
    region             = local.vpc_config.region,
    subnets            = join(",", local.vpc_config.subnets),
    security_group_ids = join(",", local.vpc_config.security_group_ids),
    vpc_id             = local.vpc_config.vpc_id,
    source_ami         = var.source_ami,
    ami_name           = var.project_name,
    instance_type      = var.instance_type,
    goss_profile       = var.goss_profile,
    playbook           = var.playbook,
    }, var.playbook == null ? {} : {
    playbook = var.playbook
    }, var.userdata == null ? {
    userdata = ""
    } : {
    userdata = var.userdata
    }, var.shared_accounts == null ? {
    shared_accounts = ""
    } : {
    shared_accounts = join(",", var.shared_accounts),
    }, var.ssh_user == null ? {} : {
    ssh_user = var.ssh_user,
    keyname  = "${var.project_name}-deployer-key"
    }
  ))
  all_parameters = merge(
    local.parameters,
    var.extra_parameters
  )
  parameters_keys = issensitive(keys(local.parameters)) ? nonsensitive(keys(local.parameters)) : keys(local.parameters)
  secrets = tomap(merge(
    var.winrm_credentials == null ? {} : { winrm_credentials = var.winrm_credentials },
    var.secrets
  ))
  secret_keys = issensitive(keys(local.secrets)) ? nonsensitive(keys(local.secrets)) : keys(local.secrets)
  ssm_parameters = merge(
    { for key, value in local.all_parameters : key => contains(["", null], value) ? "notset" : value },
    { parameters = join(",", local.parameters_keys) },
    length(local.secret_keys) > 0 ? { secrets = join(",", local.secret_keys) } : {}
  )
}

resource "aws_ssm_parameter" "parameters" {
  for_each = tomap(local.ssm_parameters)
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
  secret_string = jsonecode(lookup(local.secrets, each.key))
}
