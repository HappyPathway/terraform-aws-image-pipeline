# Purpose: Create CodeBuild projects
# this code block creates a map of build projects, where each project 
# has a set of variables and a build specification. If a project is named "build", 
# it gets some default variables and a default build specification. 
# Otherwise, it uses the variables and build specification defined 
# for the project in the build_projects variable.
locals {
  buildspec = "${path.module}/templates/buildspec_build.yml"
  build_projects = { for project in var.build_projects : (project.name) => (project.name) == "build" ? {
    vars = merge({
      packer_version  = var.packer_version,
      mitogen_version = var.mitogen_version,
      packer_config   = var.packer_config,
    }, project.vars),
    environment_variables = merge(var.environment_variables, project.environment_variables),
    buildspec             = local.buildspec
    } : {
    vars                  = project.vars
    environment_variables = merge(var.environment_variables, project.environment_variables),
    buildspec             = project.buildspec
    }
  }
}


resource "aws_codebuild_project" "terraform_codebuild_project" {
  for_each       = local.build_projects
  name           = "${var.project_name}-${each.key}"
  service_role   = var.role_arn
  encryption_key = var.kms_key_arn
  tags           = var.tags
  artifacts {
    type = var.build_project_source
  }
  environment {
    compute_type                = var.builder_compute_type
    image                       = var.builder_image
    type                        = var.builder_type
    privileged_mode             = true
    image_pull_credentials_type = var.builder_image_pull_credentials_type
    dynamic "environment_variable" {
      for_each = toset(lookup(each.value, "environment_variables", {}))
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
        type  = environment_variable.value.type
      }
    }
  }
  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }
  source {
    type = var.build_project_source
    buildspec = templatefile(
      each.value.buildspec,
      each.value.vars
    )
  }
  # secondary_sources {
  #   type = "CODECOMMIT"
  #   location = var.ansible_repo.clone_url_http
  #   source_identifier = "ansible"
  # }

  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? [] : ["*"]
    content {
      security_group_ids = var.vpc_config.security_group_ids
      subnets            = var.vpc_config.subnets
      vpc_id             = var.vpc_config.vpc_id
    }
  }

  lifecycle {
    ignore_changes = [
      project_visibility
    ]
  }
}