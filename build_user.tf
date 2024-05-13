resource "aws_iam_user" "build_user" {
  name = var.project_name
  path = "/tf-pipeline/${var.environment}/"
  tags = {
    Project_Name = var.project_name
    Environment  = var.environment
    Account_ID   = local.account_id
    Region       = local.region
  }
}

data "aws_iam_policy_document" "codecommit_access" {
  statement {
    effect = "Allow"
    actions = [
      "codecommit:GitPull",
      "codecommit:GitPush",
      "codecommit:GetBranch",
      "codecommit:CreateCommit",
      "codecommit:ListRepositories",
      "codecommit:BatchGetCommits",
      "codecommit:BatchGetRepositories",
      "codecommit:GetCommit",
      "codecommit:GetRepository",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:ListBranches",
      "codecommit:UploadArchive"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:codecommit:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:${var.source_repo_name}"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "codecommit:GitPull",
      "codecommit:GitPush",
      "codecommit:GetBranch",
      "codecommit:CreateCommit",
      "codecommit:ListRepositories",
      "codecommit:BatchGetCommits",
      "codecommit:BatchGetRepositories",
      "codecommit:GetCommit",
      "codecommit:GetRepository",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:ListBranches",
      "codecommit:UploadArchive"
    ]
    resources = [var.ansible_repo.arn]
  }
}

data "aws_iam_policy_document" "packer_config" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:AttachVolume",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CopyImage",
      "ec2:CreateImage",
      "ec2:CreateKeyPair",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteKeyPair",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSnapshot",
      "ec2:DeleteVolume",
      "ec2:DeregisterImage",
      "ec2:DescribeImageAttribute",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeRegions",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSnapshots",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DetachVolume",
      "ec2:GetPasswordData",
      "ec2:ModifyImageAttribute",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifySnapshotAttribute",
      "ec2:RegisterImage",
      "ec2:RunInstances",
      "ec2:StopInstances",
      "ec2:TerminateInstances"
      ]
    resources = ["*"]
  }
}
resource "aws_iam_access_key" "build_user" {
  user = aws_iam_user.build_user.name
}

resource "aws_iam_user_policy" "build_user" {
  for_each = tomap({
    build_permissions = var.build_permissions_iam_doc.json,
    repo_permissions  = data.aws_iam_policy_document.codecommit_access.json,
    packer_permissions = data.aws_iam_policy_document.packer_config
  })
  name   = "${var.project_name}-build-user"
  user   = aws_iam_user.build_user.name
  policy = each.value
}

resource "aws_secretsmanager_secret" "credentials" {
  name = "${var.project_name}-aws-credentials"
}

resource "aws_secretsmanager_secret_version" "credentials" {
  secret_id     = aws_secretsmanager_secret.credentials.id
  secret_string = aws_iam_access_key.build_user.secret
}