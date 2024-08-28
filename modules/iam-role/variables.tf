#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.
variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "codepipeline_iam_role_name" {
  description = "Name of the IAM role to be used by the project"
  type        = string
}

variable "tags" {
  description = "Tags to be attached to the IAM Role"
  type        = map(any)
}

variable "kms_key_arn" {
  description = "ARN of KMS key for encryption"
  type        = string
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 Bucket"
  type        = string
}

# variable "credentials_secret_arn" {
#   description = "The ARN of the AWS Secrets Manager credentials"
# }

variable "create_new_role" {
  type        = bool
  description = "Flag for deciding if a new role needs to be created"
  default     = true
}



variable "ansible_repo" {
  type = object({
    arn    = string,
    name   = optional(string, "image-pipeline-ansible-playbooks")
    branch = optional(string, "main")
  })
  description = "Source of Ansible Repo"
}

variable "ansible_bucket" {
  type = object({
    name = string,
    key  = string
  })
  description = "Ansible bucket details"
  default     = null
}


variable "goss_repo" {
  type = object({
    arn    = string,
    name   = optional(string, "image-pipeline-ansible-playbooks")
    branch = optional(string, "main")
  })
  description = "Source of Ansible Repo"
}

variable "goss_bucket" {
  type = object({
    name = string,
    key  = string
  })
  description = "Ansible bucket details"
  default     = null
}

variable "packer_repo" {
  type = object({
    arn    = string,
    name   = optional(string, "image-pipeline-ansible-playbooks")
    branch = optional(string, "main")
  })
  description = "Source of Ansible Repo"
}

variable "packer_bucket" {
  type = object({
    name = string,
    key  = string
  })
  description = "Ansible bucket details"
  default     = null
}



variable "vpc_config" {
  default = null
  type = object({
    security_group_ids = list(string)
    subnets            = list(string)
    vpc_id             = string
  })
}

variable "state" {
  type = object({
    bucket         = string
    key            = string
    region         = string
    dynamodb_table = string
  })
}

variable "image" {
  type = object({
    source_image       = string
    source_tag         = string
    dest_tag           = string
    dest_docker_repo   = string
    source_docker_repo = string
  })
  default = null
}
