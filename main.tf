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

# Move away from conditional build_user module to use static IAM role
locals {
  build_user_role_arn = aws_iam_role.build_user_role.arn
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
  packer_version                      = var.packer_version
  vpc_config                          = local.vpc_config
  terraform_version                   = var.terraform_version
  state                               = var.state
  troubleshoot                        = var.troubleshoot
  docker_build                        = var.docker_build
  environment_variables               = var.build_environment_variables
  kms_key_arn                         = module.codepipeline_kms.arn
  required_packages                   = var.required_packages
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
  packer_bucket              = var.packer_bucket
  ansible_bucket             = var.ansible_bucket
  goss_bucket                = var.goss_bucket
  pip_bucket                 = var.pip_bucket
  image                      = var.image
  kms_key_arn                = module.codepipeline_kms.arn
  shared_kms_key_arns        = var.shared_kms_key_arns
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

module "build_user" {
  source                = "./modules/build_user"
  count                 = var.create_build_user ? 1 : 0
  project_name          = var.project_name
  region                = local.region
  account_id            = local.account_id
  build_user_iam_policy = local.build_user_iam_policy
  secret_arns           = var.secret_arns
}

# Module for Infrastructure Validate, Plan, Apply and Destroy - CodePipeline
module "codepipeline_terraform" {
  depends_on = [
    module.codebuild_terraform,
    module.s3_artifacts_bucket
  ]
  source = "./modules/codepipeline"

  project_name = var.project_name

  packer_bucket         = var.packer_bucket
  ansible_bucket        = var.ansible_bucket
  goss_bucket           = var.goss_bucket
  pip_bucket            = var.pip_bucket
  s3_bucket_name        = module.s3_artifacts_bucket.bucket
  codepipeline_role_arn = module.codepipeline_iam_role.role_arn
  kms_key_arn           = module.codepipeline_kms.arn
  tags = {
    Project_Name = var.project_name
    Account_ID   = local.account_id
    Region       = local.region
  }
}

resource "aws_iam_role" "build_user_role" {
  name = "${var.project_name}-build-user-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["ec2.amazonaws.com", "codebuild.amazonaws.com"]
        }
      }
    ]
  })

  tags = {
    Project_Name = var.project_name
    Account_ID   = local.account_id
    Region       = local.region
  }
}

resource "aws_iam_role_policy" "build_user_policy" {
  name   = "${var.project_name}-build-user-policy"
  role   = aws_iam_role.build_user_role.id
  policy = local.build_user_iam_policy
}

resource "aws_iam_instance_profile" "build_user_instance_profile" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.build_user_role.name
}
