#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "role_arn" {
  description = "Codepipeline IAM role arn. "
  type        = string
  default     = ""
}

variable "assets_bucket_name" {
  description = "Name of the S3 bucket used to store the deployment artifacts"
  type        = string
  default     = "image-pipeline-assets"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket used to store the deployment artifacts"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the codebuild project"
  type        = map(any)
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
    buildspec      = optional(string)
    project_source = optional(string)
  }))
}

variable "terraform_version" {
  type = string
}

variable "builder_compute_type" {
  description = "Information about the compute resources the build project will use"
  type        = string
}

variable "builder_image" {
  description = "Docker image to use for the build project"
  type        = string
  default     = "happypathway/aws-codebuild-image-pipeline:latest"
}

variable "builder_images" {
  type = map(string)
}

variable "builder_type" {
  description = "Type of build environment to use for related builds"
  type        = string
}

variable "builder_image_pull_credentials_type" {
  description = "Type of credentials AWS CodeBuild uses to pull images in your build."
  type        = string
}

variable "build_project_source" {
  description = "Information about the build output artifact location"
  type        = string
}

variable "test_project_source" {
  description = "Information about the test output artifact location"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of KMS key for encryption"
  type        = string
}


variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
    type  = string
  }))
  default = []
}

variable "packer_version" {
  type        = string
  description = "Packer CLI Version"
  default     = "1.10.3"
}

variable "packer_config" {
  type        = string
  description = "Name of Packer Config in Repo"
  default     = "build.pkr.hcl"
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

variable "troubleshoot" {
  type    = bool
  default = false
}

variable "docker_build" {
  type    = bool
  default = false
}


variable "required_packages" {
  type = list(object({
    src  = string
    dest = string
  }))
  default = []
}
