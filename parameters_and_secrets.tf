locals {
  # Define a map of parameters for infrastructure provisioning.
  parameters = tomap(merge({
    instance_profile   = var.instance_profile == null ? "${var.project_name}-instance-profile" : var.instance_profile,
    aws_account_id     = data.aws_caller_identity.current.account_id,
    region             = local.vpc_config.region,
    subnets            = join(",", local.vpc_config.subnets),
    security_group_ids = join(",", local.vpc_config.security_group_ids),
    vpc_id             = local.vpc_config.vpc_id,
    goss_profile       = var.goss_profile,
    goss_binary        = var.goss_binary,
    playbook           = var.playbook,
    troubleshoot       = var.troubleshoot,
    volume_map         = jsonencode(var.image_volume_mapping),
    key_name           = "${var.project_name}-deployer-key-${random_pet.keyname.id}"
  },
  var.playbook == null ? {} : { playbook = var.playbook },
  var.userdata == null ? { userdata = "" } : { userdata = var.userdata },
  var.shared_accounts == null ? { shared_accounts = "" } : { shared_accounts = join(",", var.shared_accounts) },
  var.ssh_user == null ? {} : { ssh_user = var.ssh_user, keyname = "${var.project_name}-deployer-key" },
  var.image == null ? {} : merge(var.image, { dest_image = var.project_name }),
  var.ami == null ? {} : { source_ami = var.ami.source_ami, ami_name = var.project_name, instance_type = var.ami.instance_type }))

  all_parameters = merge(local.parameters, var.extra_parameters)

  parameters_keys = concat(
    issensitive(keys(local.all_parameters)) ? nonsensitive(keys(local.all_parameters)) : keys(local.all_parameters),
    length(local.secret_keys) > 0 ? ["secrets"] : []
  )

  secrets = tomap(merge(
    var.winrm_credentials == null ? {} : { winrm_credentials = var.winrm_credentials },
    var.secrets
  ))

  secret_keys = issensitive(keys(local.secrets)) ? nonsensitive(keys(local.secrets)) : keys(local.secrets)

  ssm_parameters = merge(
    { for key, value in local.all_parameters : key => contains(["", null], value) ? "notset" : value },
    length(local.parameters_keys) > 0 ? { parameters = join(",", local.parameters_keys) } : {},
    length(local.secret_keys) > 0 ? { secrets = join(",", local.secret_keys) } : {}
  )

  nonsensitive_parameters = tomap(
    { for k, v in local.ssm_parameters :
      (issensitive(k) ? nonsensitive(k) : k) => (issensitive(v) ? nonsensitive(v) : v)
      if ! contains(var.nonmanaged_parameters, issensitive(k) ? nonsensitive(k) : k)
    }
  )
}

resource "aws_ssm_parameter" "managed_parameters" {
  for_each = local.nonsensitive_parameters
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
  secret_string = jsonencode(lookup(local.secrets, each.key))
}
