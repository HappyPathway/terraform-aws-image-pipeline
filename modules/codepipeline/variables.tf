#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

variable "project_name" {
  description = "Unique name for this project"
  type        = string
}



variable "s3_bucket_name" {
  description = "S3 bucket name to be used for storing the artifacts"
  type        = string
}

variable "codepipeline_role_arn" {
  description = "ARN of the codepipeline IAM role"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of KMS key for encryption"
  type        = string
}

variable "tags" {
  description = "Tags to be attached to the CodePipeline"
  type        = map(any)
}

variable "packer_bucket" {
  description = "Source bucket details"
  type = object({
    name = string,
    key  = string
  })
  default = null
}

variable "ansible_bucket" {
  description = "Ansible bucket details"
  type = object({
    name = string,
    key  = string
  })
  default = null
}

variable "goss_bucket" {
  description = "Goss bucket details"
  type = object({
    name = string,
    key  = string
  })
  default = null
}

variable "pip_bucket" {
  type = object({
    name = string,
    key  = string
  })
  description = "Ansible bucket details"
  default     = null
}