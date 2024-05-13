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

resource "aws_iam_access_key" "build_user" {
  user = aws_iam_user.build_user.name
}

resource "aws_iam_user_policy" "build_user" {
  for_each = tomap({
    build_permissions = var.build_permissions_iam_doc.json,
    repo_permissions  = data.aws_iam_policy_document.codecommit_access.json
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