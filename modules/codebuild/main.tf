locals {
  # Define paths to buildspec templates
  buildspecs = {
    build       = "${path.module}/templates/buildspec_build.yml"
    test        = "${path.module}/templates/buildspec_test.yml"
    docker_test = "${path.module}/templates/buildspec_docker_test.yml"
  }

  # Conditionally include a docker_test build project if docker_test_enabled is true
  _build_projects = var.docker_test_enabled ? concat(
    # Include all build projects except the one named "test"
    [for project in var.build_projects : project if project.name != "test"],
    # Add a new "test" project with docker_test buildspec
    [{
      name                  = "test"
      vars                  = {}
      environment_variables = []
      buildspec             = local.buildspecs.docker_test
      project_source        = var.build_project_source
    }]
  ) : var.build_projects

  # Create a map of build projects with merged variables and environment settings
  build_projects = {
    for project in local._build_projects : project.name => {
      # Merge common variables with project-specific variables
      vars = merge({
        project_name      = var.project_name,
        packer_version    = var.packer_version,
        mitogen_version   = var.mitogen_version,
        packer_config     = var.packer_config,
        terraform_version = var.terraform_version,
        troubleshoot      = lower(tostring(var.troubleshoot))
      }, project.vars)
      # Concatenate common environment variables with project-specific ones
      environment_variables = concat(var.environment_variables, project.environment_variables)
      # Lookup the buildspec for the project, defaulting to the one in buildspecs map
      buildspec = lookup(project, "buildspec", lookup(local.buildspecs, project.name))
      # Lookup the project source, defaulting to the common project source
      build_project_source = lookup(project, "project_source", var.build_project_source)
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

  cache {
    type     = "S3"
    location = var.s3_bucket_name
  }

  environment {
    compute_type                = var.builder_compute_type
    image                       = lookup(var.builder_images, each.key, var.builder_image)
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
      lookup(each.value, "buildspec", lookup(local.buildspecs, each.key)),
      each.key != "test" ? each.value.vars : merge(each.value.vars, { state = merge(var.state, { bucket = var.s3_bucket_name }) })
    )
  }

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
