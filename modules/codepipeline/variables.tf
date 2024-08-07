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

variable "stages" {
  description = "List of Map containing information about the stages of the CodePipeline"
  type = list(object({
    name             = string,
    category         = string,
    owner            = string,
    provider         = string,
    input_artifacts  = list(string),
    output_artifacts = list(string)
  }))
}

variable "packer_source_type" {
  description = "Type of source to be used for the CodePipeline"
  type        = string
  default     = "CodeCommit"
}

variable "packer_bucket" {
  description = "Source bucket details"
  type = object({
    name = string,
    key  = string
  })
  default = null
}

variable "packer_repo" {
  type = object({
    clone_url_http = string,
    arn            = string,
    name           = optional(string, "image-pipeline-ansible-playbooks")
    branch         = optional(string, "main")
  })
  description = "Source of the Terraform Repo"
  default     = null
}


variable "ansible_source_type" {
  description = "Type of source to be used for the Ansible CodePipeline"
  type        = string
  default     = "CodeCommit"
}

variable "ansible_bucket" {
  description = "Ansible bucket details"
  type = object({
    name = string,
    key  = string
  })
  default = null
}

variable "ansible_repo" {
  type = object({
    clone_url_http = string,
    arn            = string,
    name           = optional(string, "image-pipeline-ansible-playbooks")
    branch         = optional(string, "main")
  })
  description = "Source of Ansible Repo"
  default     = null
}


variable "goss_source_type" {
  description = "Type of source to be used for the Goss CodePipeline"
  type        = string
  default     = "CodeCommit"
}

variable "goss_repo" {
  type = object({
    clone_url_http = string,
    arn            = string,
    name           = optional(string, "image-pipeline-ansible-playbooks")
    branch         = optional(string, "main")
  })
  description = "Source of Ansible Repo"
  default     = null
}

variable "goss_bucket" {
  description = "Goss bucket details"
  type = object({
    name = string,
    key  = string
  })
  default = null
}