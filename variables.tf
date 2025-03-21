#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "create_new_role" {
  description = "Whether to create a new IAM Role. Values are true or false. Defaulted to true always."
  type        = bool
  default     = true
}

variable "codepipeline_iam_role_name" {
  description = "Name of the IAM role to be used by the Codepipeline"
  type        = string
  default     = "codepipeline-role"
}

# variable "repo_approvers_arn" {
#   description = "ARN or ARN pattern for the IAM User/Role/Group that can be used for approving Pull Requests"
#   type        = string
# }


variable "build_projects" {
  description = "List of Names of the CodeBuild projects to be created"
  type = list(object({
    name = string,
    vars = optional(map(string), {})
    environment_variables = optional(list(object({
      name  = string
      value = string
      type  = string
    })), [])
    buildspec = optional(string)
  }))
  default = [
    {
      name = "build"
    },
    {
      name = "test"
    }
  ]
}

variable "builder_compute_type" {
  description = "Relative path to the Apply and Destroy build spec file"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "builder_image" {
  description = "Docker Image to be used by codebuild"
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
}

variable "builder_images" {
  type    = map(string)
  default = {}
}

variable "builder_type" {
  description = "Type of codebuild run environment"
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "builder_image_pull_credentials_type" {
  description = "Image pull credentials type used by codebuild project"
  type        = string
  default     = "CODEBUILD"
}

variable "build_project_source" {
  description = "Source Code Repo for Playbook"
  type        = string
  default     = "CODEPIPELINE"
}

variable "test_project_source" {
  description = "Source Code Repo for Goss Testing Suite"
  type        = string
  default     = "CODEPIPELINE"
}

variable "build_environment_variables" {
  type = list(object({
    name  = string
    value = string
    type  = optional(string, "PLAINTEXT")
  }))
  default = null
}

variable "packer_version" {
  type        = string
  description = "Terraform CLI Version"
  default     = "1.10.3"
}

variable "packer_config" {
  type        = string
  description = "Name of Packer Config in Repo"
  default     = "build.pkr.hcl"
}

variable "packer_bucket" {
  type = object({
    name = string,
    key  = string
  })
  description = "Source bucket details"
  default     = null
}

variable "ansible_bucket" {
  type = object({
    name = string,
    key  = string,
  })
  description = "Ansible bucket details"
  default     = null
}

variable "pip_bucket" {
  type = object({
    name = string,
    key  = string,
  })
  description = "Pip bucket details"
  default     = null
}

variable "goss_bucket" {
  type = object({
    name = string,
    key  = string,
  })
  description = "Goss bucket details"
  default     = null
}

variable "vpc_config" {
  default = null
  type = object({
    security_group_ids = list(string)
    subnets            = list(string)
    vpc_id             = string
    region             = string
  })
}

variable "terraform_version" {
  type    = string
  default = "1.3.10"
}

variable "state" {
  type = object({
    bucket         = string
    key            = string
    region         = string
    dynamodb_table = string
  })
}

variable "ssh_user" {
  type        = string
  description = "SSH username"
  default     = null
}

variable "goss_profile" {
  type        = string
  description = "GOSS Profile to be used for testing"
  default     = "goss"
}

variable "goss_binary" {
  type        = string
  description = "GOSS Profile to be used for testing"
  default     = "goss-linux-amd64"
}




variable "extra_parameters" {
  type    = map(string)
  default = {}
}

variable "secrets" {
  type      = map(string)
  sensitive = true
  default   = {}
}

variable "winrm_credentials" {
  type = object({
    username = string
    password = string
  })
  default = null
}

variable "shared_accounts" {
  type    = list(string)
  default = null
}

variable "playbook" {
  type    = string
  default = null
}

variable "userdata" {
  type    = string
  default = null
}

variable "troubleshoot" {
  type    = bool
  default = false
}

variable "image" {
  type = object({
    dest_tag           = string
    dest_docker_repo   = string
    source_image       = string
    source_tag         = string
    source_docker_repo = string
  })
  default = null
}

variable "ami" {
  type = object({
    instance_type = string
    source_ami    = string
  })
  default = null
}

variable "docker_build" {
  type    = bool
  default = false
}

variable "nonmanaged_parameters" {
  type = list(string)
  default = [
    "dest_tag"
  ]
}

variable "build_user_iam_policy" {
  description = "The IAM policy for the build user."
  type        = string
  default     = null
}

variable "parameter_arns" {
  type    = list(string)
  default = null
}

variable "secret_arns" {
  type    = list(string)
  default = null
}

variable "shared_kms_key_arns" {
  type    = list(string)
  default = []
}

variable "kms_key_id" {
  type    = string
  default = null
}

variable "required_packages" {
  type = list(object({
    src  = string
    dest = string
  }))
  default = []
}

variable "assets_bucket_name" {
  description = "Name of the S3 bucket used to store the deployment artifacts"
  type        = string
  default     = "image-pipeline-assets"
}

variable "instance_profile" {
  type    = string
  default = null
}

variable "image_volume_mapping" {
  type = list(object({
    device_name           = string
    volume_size           = number
    volume_type           = string
    delete_on_termination = bool
    encrypted             = optional(bool, false)
    iops                  = optional(number, null)
    snapshot_id           = optional(string, null)
    throughput            = optional(number, null)
    virtual_name          = optional(string, null)
    kms_key_id            = optional(string, null)
    mount_path            = optional(string, null)
  }))
  default = []
}

variable "create_build_user" {
  description = "Whether to create a build user. Set to false if you want to use an existing user."
  type        = bool
  default     = true
}
