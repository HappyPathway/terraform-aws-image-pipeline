// variables.tf

variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "account_id" {
  description = "The AWS account ID."
  type        = string
}

variable "region" {
  description = "The AWS region."
  type        = string
}

variable "build_user_iam_policy" {
  description = "The IAM policy for the build user."
  type        = string
}
