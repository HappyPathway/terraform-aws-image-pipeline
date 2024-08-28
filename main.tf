#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.1"
    }
  }

}

#Module for creating a new S3 bucket for storing pipeline artifacts
module "s3_artifacts_bucket" {
  source                = "./modules/s3"
  project_name          = var.project_name
  kms_key_arn           = module.codepipeline_kms.arn
  codepipeline_role_arn = module.codepipeline_iam_role.role_arn
  tags = {
    Project_Name = var.project_name
    Account_ID   = local.account_id
    Region       = local.region
  }
}

# Resources

# Module for Infrastructure Source code repository
module "codecommit_infrastructure_source_repo" {
  source             = "./modules/codecommit"
  count              = var.packer_source_type == "CodeCommit" ? 1 : 0
  create_new_repo    = var.create_new_repo
  packer_repo        = var.packer_repo
  repo_approvers_arn = local.approver_role
  kms_key_arn        = module.codepipeline_kms.arn
  tags = {
    Project_Name = var.project_name
    Account_ID   = local.account_id
    Region       = local.region
  }

}


module "codepipeline_kms" {
  source                = "./modules/kms"
  codepipeline_role_arn = module.codepipeline_iam_role.role_arn
  tags = {
    Project_Name = var.project_name
    Account_ID   = local.account_id
    Region       = local.region
  }
}

# Module for Infrastructure Validation - CodeBuild
module "codebuild_terraform" {
  depends_on = [
    module.codecommit_infrastructure_source_repo
  ]
  source = "./modules/codebuild"

  project_name                        = var.project_name
  role_arn                            = module.codepipeline_iam_role.role_arn
  s3_bucket_name                      = module.s3_artifacts_bucket.bucket
  build_projects                      = var.build_projects
  build_project_source                = var.build_project_source
  test_project_source                 = var.test_project_source
  builder_compute_type                = var.builder_compute_type
  builder_image                       = var.builder_image
  builder_images                      = var.builder_images
  builder_image_pull_credentials_type = var.builder_image_pull_credentials_type
  builder_type                        = var.builder_type
  packer_config                       = var.packer_config
  vpc_config                          = local.vpc_config
  terraform_version                   = var.terraform_version
  state                               = var.state
  troubleshoot                        = var.troubleshoot
  docker_test_enabled                 = var.docker_test_enabled
  environment_variables = concat(
    var.build_environment_variables,
    var.vpc_config != null ? [
      {
        name  = "PKR_VAR_security_group_id",
        value = element(var.vpc_config.security_group_ids, 0),
        type  = "PLAINTEXT"
      },
      {
        name  = "PKR_VAR_subnet_id",
        value = element(var.vpc_config.subnets, 0),
        type  = "PLAINTEXT"
      }
    ] : []
  )
  kms_key_arn = module.codepipeline_kms.arn

  tags = {
    Project_Name = var.project_name
    Account_ID   = local.account_id
    Region       = local.region
  }
}

module "codepipeline_iam_role" {
  source                     = "./modules/iam-role"
  project_name               = var.project_name
  create_new_role            = var.create_new_role
  codepipeline_iam_role_name = var.create_new_role == true ? "${var.project_name}-codepipeline-role" : var.codepipeline_iam_role_name
  packer_repo                = var.packer_repo
  packer_bucket              = var.packer_bucket
  ansible_repo               = var.ansible_repo
  ansible_bucket             = var.ansible_bucket
  goss_repo                  = var.goss_repo
  goss_bucket                = var.goss_bucket
  image                      = var.image
  kms_key_arn                = module.codepipeline_kms.arn
  s3_bucket_arn              = module.s3_artifacts_bucket.arn
  # credentials_secret_arn     = aws_secretsmanager_secret.credentials.arn
  vpc_config = local.vpc_config
  state      = var.state
  tags = {
    Project_Name = var.project_name
    Account_ID   = local.account_id
    Region       = local.region
  }
}



# Module for Infrastructure Validate, Plan, Apply and Destroy - CodePipeline
module "codepipeline_terraform" {
  depends_on = [
    module.codebuild_terraform,
    module.s3_artifacts_bucket
  ]
  source = "./modules/codepipeline"

  project_name = var.project_name

  packer_source_type = var.packer_source_type
  packer_repo        = var.packer_repo
  packer_bucket      = var.packer_bucket

  ansible_source_type = var.ansible_source_type
  ansible_repo        = var.ansible_repo
  ansible_bucket      = var.ansible_bucket

  goss_source_type = var.goss_source_type
  goss_repo        = var.goss_repo
  goss_bucket      = var.goss_bucket

  s3_bucket_name        = module.s3_artifacts_bucket.bucket
  codepipeline_role_arn = module.codepipeline_iam_role.role_arn
  stages                = var.stage_input
  kms_key_arn           = module.codepipeline_kms.arn
  tags = {
    Project_Name = var.project_name
    Account_ID   = local.account_id
    Region       = local.region
  }
}
