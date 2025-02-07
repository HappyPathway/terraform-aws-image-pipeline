#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  buckets = distinct([
    module.s3_artifacts_bucket.bucket,
    var.assets_bucket_name,
    var.packer_bucket.name,
    var.ansible_bucket.name,
    var.goss_bucket.name,
    var.state.bucket
  ])
}

data "aws_iam_policy_document" "build_user_default" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:*"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:kms:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:*"
    ]
    resources = concat([
      "arn:${data.aws_partition.current.partition}:secretsmanager:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:secret:/image-pipeline/${var.project_name}/*"
      ],
    var.secret_arns == null ? [] : var.secret_arns)
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = concat(
      [
        for bucket in local.buckets : "arn:${data.aws_partition.current.partition}:s3:::${bucket}"
      ],
      [
        for bucket in local.buckets : "arn:${data.aws_partition.current.partition}:s3:::${bucket}/*"
      ]
    )
  }
}

locals {
  build_user_iam_policy = var.build_user_iam_policy == null ? data.aws_iam_policy_document.build_user_default.json : var.build_user_iam_policy
}
