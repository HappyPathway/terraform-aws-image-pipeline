#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

output "codecommit_name" {
  value       = var.packer_source_type == "CodeCommit" && var.create_new_repo ? (module.codecommit_infrastructure_source_repo).repository_name : null
  description = "The name of the Codecommit repository"
}

output "codecommit_url" {
  value       = var.packer_source_type == "CodeCommit" && var.create_new_repo ? one(module.codecommit_infrastructure_source_repo).clone_url_http : null
  description = "The Clone URL of the Codecommit repository"
}

output "codecommit_arn" {
  value       = var.packer_source_type == "CodeCommit" && var.create_new_repo ? one(module.codecommit_infrastructure_source_repo).arn : null
  description = "The ARN of the Codecommit repository"
}

# output "codebuild_name" {
#   value       = module.codebuild_terraform.name
#   description = "The Name of the Codebuild Project"
# }

# output "codebuild_arn" {
#   value       = module.codebuild_terraform.arn
#   description = "The ARN of the Codebuild Project"
# }

output "codepipeline_name" {
  value       = module.codepipeline_terraform.name
  description = "The Name of the CodePipeline"
}

output "codepipeline_arn" {
  value       = module.codepipeline_terraform.arn
  description = "The ARN of the CodePipeline"
}

output "iam_arn" {
  value       = module.codepipeline_iam_role.role_arn
  description = "The ARN of the IAM Role used by the CodePipeline"
}

output "kms_arn" {
  value       = module.codepipeline_kms.arn
  description = "The ARN of the KMS key used in the codepipeline"
}

output "s3_arn" {
  value       = module.s3_artifacts_bucket.arn
  description = "The ARN of the S3 Bucket"
}

output "s3_bucket" {
  value       = module.s3_artifacts_bucket.bucket
  description = "The Name of the S3 Bucket"
}

# output "build_user" {
#   value = aws_iam_user.build_user
# }

output "sec_group" {
  value = aws_security_group.packer
}

output "parameters" {
  value = aws_ssm_parameter.parameters
}

output "secrets" {
  value = aws_secretsmanager_secret.secrets
}