
locals {
  # Define a map of parameters for infrastructure provisioning.
  # This includes configurations like region, subnets, security group IDs, VPC ID, source AMI, and more.
  # Conditional logic is used to include optional parameters only if they are provided.
  parameters = tomap(merge({
    region             = local.vpc_config.region,                        # AWS region where resources will be provisioned.
    subnets            = join(",", local.vpc_config.subnets),            # Comma-separated list of subnet IDs.
    security_group_ids = join(",", local.vpc_config.security_group_ids), # Comma-separated list of security group IDs.
    vpc_id             = local.vpc_config.vpc_id,                        # VPC ID where resources will be provisioned.
    source_ami         = var.source_ami,                                 # AMI ID used as the base image for instances.
    ami_name           = var.project_name,                               # Name assigned to the AMI created.
    instance_type      = var.instance_type,                              # EC2 instance type.
    goss_profile       = var.goss_profile,                               # GOSS profile for server testing.
    playbook           = var.playbook,                                   # Ansible playbook for configuration management.
    }, var.playbook == null ? {} : {
    playbook = var.playbook # Include playbook if provided.
    }, var.userdata == null ? {
    userdata = "" # Default userdata to an empty string if not provided.
    } : {
    userdata = var.userdata # Userdata script for instance initialization.
    }, var.shared_accounts == null ? {
    shared_accounts = "" # Default shared accounts to an empty string if not provided.
    } : {
    shared_accounts = join(",", var.shared_accounts), # Comma-separated list of shared AWS account IDs.
    }, var.ssh_user == null ? {} : {
    ssh_user = var.ssh_user,                      # SSH username for instance access.
    keyname  = "${var.project_name}-deployer-key" # Key pair name for SSH access.
    }
  ))

  # Merge base parameters with any extra parameters provided.
  all_parameters = merge(
    local.parameters,
    var.extra_parameters # Extra parameters that can be passed for additional customization.
  )

  # Extract keys from the parameters map, handling sensitive keys appropriately.
  parameters_keys = concat(
    issensitive(keys(local.parameters)) ? nonsensitive(keys(local.parameters)) : keys(local.parameters),
    length(local.secret_keys) > 0 ? ["secrets"] : [] # Include secret keys if there's any secrets.
  )

  # Define a map of secrets, such as WinRM credentials and other sensitive information.
  secrets = tomap(merge(
    var.winrm_credentials == null ? {} : { winrm_credentials = var.winrm_credentials }, # Include WinRM credentials if provided.
    var.secrets                                                                         # Additional secrets provided as a map.
  ))

  # Extract keys from the secrets map, handling sensitive keys appropriately.
  secret_keys = issensitive(keys(local.secrets)) ? nonsensitive(keys(local.secrets)) : keys(local.secrets)

  # Prepare parameters for AWS Systems Manager (SSM) Parameter Store.
  # Replace empty or null values with "notset" and compile lists of parameter and secret keys.
  ssm_parameters = merge(
    { for key, value in local.all_parameters : key => contains(["", null], value) ? "notset" : value }, # Replace empty/null values with "notset".
    length(local.parameters_keys) > 0 ? { parameters = join(",", local.parameters_keys) } : {},         # Compile a comma-separated list of parameter keys.
    length(local.secret_keys) > 0 ? { secrets = join(",", local.secret_keys) } : {}                     # Compile a comma-separated list of secret keys if any.
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
  secret_string = jsonencode(lookup(local.secrets, each.key))
}
