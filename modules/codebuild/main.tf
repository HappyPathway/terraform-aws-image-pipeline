# Purpose: Create CodeBuild projects
locals {
  buildspecs = {
    build        = "${path.module}/templates/buildspec_build.yml"
    test         = "${path.module}/templates/buildspec_test.yml"
    docker_test  = "${path.module}/templates/buildspec_docker_test.yml"
    docker_build = "${path.module}/templates/buildspec_docker_build.yml"
  }
  # This Terraform code block is creating a map of build projects using a for loop. 
  # It's iterating over the build_projects variable, which is expected to be a list of 
  # maps where each map represents a build project.

  # For each project, it checks the project's name:
  # If the project's name is "build", it creates a map with the following keys:
  # vars: This is a map that merges a predefined map (containing packer_version, and packer_config) 
  # with the vars from the current project.
  # environment_variables: This is a list that concatenates a predefined list of 
  # environment variables with the environment_variables from the current project.
  # buildspec: This is set to a local value buildspec.

  # If the project's name is "test", it creates a map with the following keys:
  # vars: This is set to the vars from the current project.
  # environment_variables: This is a list that concatenates a predefined list of environment variables with the environment_variables from the current project.
  # buildspec: This is set to "test_buildspec.yml".

  # If the project's name is neither "build" nor "test", it creates a map with the following keys:
  # vars: This is set to the vars from the current project.
  # environment_variables: This is a list that concatenates a predefined list of 
  # environment variables with the environment_variables from the current project.
  # buildspec: This is set to the buildspec from the current project.

  # The result of this for loop is a map where each key is a project name and each 
  # value is a map with keys vars, environment_variables, and buildspec. 
  # This map is assigned to the build_projects local value.
  _build_projects = var.docker_build ? concat([
    for project in var.build_projects : project if !contains(["test", "build"], project.name)
    ],
    [
      {
        name                  = "build"
        vars                  = {}
        environment_variables = []
        buildspec             = lookup(local.buildspecs, "docker_build")
        project_source        = var.build_project_source
      },
      {
        name                  = "test"
        vars                  = {}
        environment_variables = []
        buildspec             = lookup(local.buildspecs, "docker_test")
        project_source        = var.build_project_source
      }
    ]
  ) : var.build_projects
  build_projects = { for project in local._build_projects : (project.name) =>
    (project.name) == "build" ? {
      vars = merge({
        packer_version            = var.packer_version,
        packer_config             = var.packer_config,
        project_name              = var.project_name,
        ssh_private_key_secret_id = "/image-pipeline/${var.project_name}/ssh-private-key",
        ssh_private_key_file      = "/tmp/${var.project_name}-ssh-private-key.pem",

      }, project.vars),
      environment_variables = concat(var.environment_variables, project.environment_variables),
      buildspec             = lookup(project, "buildspec", lookup(local.buildspecs, project.name))
      build_project_source  = lookup(project, "project_source", var.build_project_source)
      } : contains(["test", "docker_test"], project.name) ? {
      vars = merge({
        project_name      = var.project_name,
        terraform_version = var.terraform_version
        troubleshoot      = lower(tostring(var.troubleshoot))
      }, project.vars)
      environment_variables = concat(var.environment_variables, project.environment_variables),
      buildspec             = lookup(project, "buildspec", lookup(local.buildspecs, project.name))
      build_project_source  = lookup(project, "project_source", var.test_project_source)
      } : {
      vars                  = project.vars
      environment_variables = concat(var.environment_variables, project.environment_variables),
      buildspec             = project.buildspec
      build_project_source  = project.project_source
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
    # 
    # The test phase requires a state backend whereas the build phase does not.
    # that's the whole reason for this code here.
    #
    # if key is test, then use the test template which uses state variables.
    buildspec = each.key != "test" ? templatefile(
      lookup(each.value, "buildspec") == null ? lookup(local.buildspecs, each.key) : lookup(each.value, "buildspec"),
      merge(
        each.value.vars,
        {
          required_packages = jsonencode(var.required_packages),
          bucket            = var.assets_bucket_name,
        }
      )) : templatefile(
      lookup(each.value, "buildspec") == null ? lookup(local.buildspecs, each.key) : lookup(each.value, "buildspec"),
      merge(
        each.value.vars,
        {
          state = merge(var.state, { bucket = var.s3_bucket_name })
        }
    ))
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
