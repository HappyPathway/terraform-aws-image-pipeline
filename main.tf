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
    Environment  = var.environment
    Account_ID   = local.account_id
    Region       = local.region
  }
}

# Resources

# Module for Infrastructure Source code repository
module "codecommit_infrastructure_source_repo" {
  source = "./modules/codecommit"

  create_new_repo          = var.create_new_repo
  source_repository_name   = var.source_repo_name
  source_repository_branch = var.source_repo_branch
  repo_approvers_arn       = local.approver_role
  kms_key_arn              = module.codepipeline_kms.arn
  tags = {
    Project_Name = var.project_name
    Environment  = var.environment
    Account_ID   = local.account_id
    Region       = local.region
  }

}


module "codepipeline_kms" {
  source                = "./modules/kms"
  codepipeline_role_arn = module.codepipeline_iam_role.role_arn
  tags = {
    Project_Name = var.project_name
    Environment  = var.environment
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
  environment                         = var.environment
  role_arn                            = module.codepipeline_iam_role.role_arn
  s3_bucket_name                      = module.s3_artifacts_bucket.bucket
  build_projects                      = var.build_projects
  build_project_source                = var.build_project_source
  test_project_source                 = var.test_project_source
  builder_compute_type                = var.builder_compute_type
  builder_image                       = var.builder_image
  builder_image_pull_credentials_type = var.builder_image_pull_credentials_type
  builder_type                        = var.builder_type
  vpc_config                          = local.vpc_config
  terraform_version                   = var.terraform_version
  state                               = var.state
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
    Environment  = var.environment
    Account_ID   = local.account_id
    Region       = local.region
  }
}

module "codepipeline_iam_role" {
  source                     = "./modules/iam-role"
  project_name               = var.project_name
  environment                = var.environment
  create_new_role            = var.create_new_role
  codepipeline_iam_role_name = var.create_new_role == true ? "${var.project_name}-codepipeline-role" : var.codepipeline_iam_role_name
  source_repository_name     = var.source_repo_name
  ansible_repo               = var.ansible_repo
  goss_repo                  = var.goss_repo
  kms_key_arn                = module.codepipeline_kms.arn
  s3_bucket_arn              = module.s3_artifacts_bucket.arn
  credentials_secret_arn     = aws_secretsmanager_secret.credentials.arn
  vpc_config                 = local.vpc_config
  state                      = var.state
  tags = {
    Project_Name = var.project_name
    Environment  = var.environment
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

  project_name          = var.project_name
  source_repo_name      = var.source_repo_name
  source_repo_branch    = var.source_repo_branch
  ansible_repo          = var.ansible_repo
  goss_repo             = var.goss_repo
  s3_bucket_name        = module.s3_artifacts_bucket.bucket
  codepipeline_role_arn = module.codepipeline_iam_role.role_arn
  stages                = var.stage_input
  kms_key_arn           = module.codepipeline_kms.arn
  tags = {
    Project_Name = var.project_name
    Environment  = var.environment
    Account_ID   = local.account_id
    Region       = local.region
  }
}
