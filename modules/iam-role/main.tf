#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

data "aws_iam_policy_document" "codepipeline_assume_role" {
  # iam:GetInstanceProfile
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codepipeline_role" {
  count              = var.create_new_role ? 1 : 0
  name               = var.codepipeline_iam_role_name
  tags               = var.tags
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
  path               = "/"
}

locals {
  # Construct bucket ARNs directly since we know the bucket name
  assets_bucket_arns = distinct([
    "arn:${data.aws_partition.current.partition}:s3:::${var.goss_bucket.name}",
    "arn:${data.aws_partition.current.partition}:s3:::${var.goss_bucket.name}/*",
    "arn:${data.aws_partition.current.partition}:s3:::${var.ansible_bucket.name}",
    "arn:${data.aws_partition.current.partition}:s3:::${var.ansible_bucket.name}/*",
    "arn:${data.aws_partition.current.partition}:s3:::${var.packer_bucket.name}",
    "arn:${data.aws_partition.current.partition}:s3:::${var.packer_bucket.name}/*",
    "arn:${data.aws_partition.current.partition}:s3:::${var.pip_bucket.name}",
    "arn:${data.aws_partition.current.partition}:s3:::${var.pip_bucket.name}/*"
  ])
}

data "aws_iam_policy_document" "codepipeline_policy" {

  # statement {
  #   effect = "Allow"
  #   actions = [
  #     "secretsmanager:GetSecretValue"
  #   ]
  #   resources = [var.credentials_secret_arn]
  # }

  statement {
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = distinct(concat([
      "${var.s3_bucket_arn}/*",
      "arn:${data.aws_partition.current.partition}:s3:::${var.state.bucket}/*"
      ],
      local.assets_bucket_arns
    ))
  }
  statement {
    effect = "Allow"
    actions = [
      "iam:Get*",
      "iam:PassRole",
      "iam:List*"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ssm:*"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:parameter/image-pipeline/${var.project_name}/*",
      "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:parameter/image-pipeline/global/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:*"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:secretsmanager:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:secret:/image-pipeline/${var.project_name}/*",
      "arn:${data.aws_partition.current.partition}:secretsmanager:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:secret:/image-pipeline/global/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:Decrypt"
    ]
    resources = concat([
      var.kms_key_arn
      ],
      var.shared_kms_key_arns == null ? [] :
      var.shared_kms_key_arns
    )
  }
  dynamic "statement" {
    for_each = var.image == null ? [] : ["*"]
    content {
      effect = "Allow"
      actions = [
        "ecr:*"
      ]
      resources = concat([
        "arn:${data.aws_partition.current.partition}:ecr:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:repository/${var.image.dest_docker_repo}",
        "arn:${data.aws_partition.current.partition}:ecr:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:repository/${var.image.dest_docker_repo}/*"
        ],
        var.image.source_docker_repo == var.image.dest_docker_repo ? [] : [
          "arn:${data.aws_partition.current.partition}:ecr:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:repository/${var.image.source_docker_repo}",
          "arn:${data.aws_partition.current.partition}:ecr:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:repository/${var.image.source_docker_repo}/*"
      ])
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:ImportKeyPair"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:key-pair/${var.project_name}-deployer-key"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:BatchGetProjects"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:codebuild:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:project/${var.project_name}*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:codebuild:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:report-group/${var.project_name}*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:*",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:dynamodb:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:table/${var.state.dynamodb_table}"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:*"
    ]
    resources = ["*"]
  }
}

# TO-DO : replace all * with resource names / arn
resource "aws_iam_policy" "codepipeline_policy" {
  count       = var.create_new_role ? 1 : 0
  name        = "${var.project_name}-codepipeline-policy"
  description = "Policy to allow codepipeline to execute"
  tags        = var.tags
  policy      = data.aws_iam_policy_document.codepipeline_policy.json
}

resource "aws_iam_role_policy_attachment" "codepipeline_role_attach" {
  count      = var.create_new_role ? 1 : 0
  role       = one(aws_iam_role.codepipeline_role).name
  policy_arn = one(aws_iam_policy.codepipeline_policy).arn
}

# aws_iam_policy" "vpc_config"
resource "aws_iam_role_policy_attachment" "codepipeline_vpc_role_attach" {
  count      = var.vpc_config == null ? 0 : 1
  role       = one(aws_iam_role.codepipeline_role).name
  policy_arn = one(aws_iam_policy.vpc_config).arn
}
