#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "create_new_repo" {
  description = "Whether to create a new repository. Values are true or false. Defaulted to true always."
  type        = bool
  default     = true
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

variable "source_repo_name" {
  description = "Source repo name of the CodeCommit repository"
  type        = string
}

variable "source_repo_branch" {
  description = "Default branch in the Source repo for which CodePipeline needs to be configured"
  type        = string
}

# variable "repo_approvers_arn" {
#   description = "ARN or ARN pattern for the IAM User/Role/Group that can be used for approving Pull Requests"
#   type        = string
# }

variable "environment" {
  description = "Environment in which the script is run. Eg: dev, prod, etc"
  type        = string
}

variable "stage_input" {
  description = "Tags to be attached to the CodePipeline"
  type = list(object({
    name             = string,
    category         = string,
    owner            = string,
    provider         = string,
    input_artifacts  = list(string),
    output_artifacts = list(string)
  }))
  default = [
    {
      name             = "build",
      category         = "Build",
      owner            = "AWS",
      provider         = "CodeBuild",
      input_artifacts  = ["SourceOutput", "SourceAnsibleOutput"],
      output_artifacts = ["BuildOutput"]
    },
    {
      name             = "test",
      category         = "Build",
      owner            = "AWS",
      provider         = "CodeBuild",
      input_artifacts  = ["SourceOutput", "SourceGossOutput"],
      output_artifacts = ["BuildTestOutput"]
    },
  ]
}


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
  default = []
}

variable "packer_version" {
  type        = string
  description = "Terraform CLI Version"
  default     = "1.10.3"
}

variable "mitogen_version" {
  type        = string
  description = "Mitogen Version"
  default     = "0.3.7"
}

variable "packer_config" {
  type        = string
  description = "Name of Packer Config in Repo"
  default     = "build.pkr.hcl"
}

variable "build_permissions_iam_doc" {
  type = any
}


variable "ansible_repo" {
  type = object({
    clone_url_http = string,
    arn            = string,
    name           = optional(string, "image-pipeline-ansible-roles")
    branch         = optional(string, "main")
  })
  description = "Source of Ansible Repo"
}


variable "goss_repo" {
  type = object({
    clone_url_http = string,
    arn            = string,
    name           = optional(string, "image-pipeline-goss-testing")
    branch         = optional(string, "main")
  })
  description = "Source of Goss Repo"
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
  default     = "ec2-user"
}

variable "goss_profile" {
  type        = string
  description = "GOSS Profile to be used for testing"
  default     = "goss"
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

variable "source_ami" {
  type = string
}

variable "image_version" {
  type = string
}

variable "shared_accounts" {
  type = list(string)
}

variable "instance_type" {
  type = string
}

variable "playbook" {
  type = string
}

variable "userdata" {
  type = string
}
