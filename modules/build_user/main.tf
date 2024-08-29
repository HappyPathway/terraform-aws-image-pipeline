resource "aws_iam_user" "build_user" {
  name = var.project_name
  path = "/tf-pipeline/"
  tags = {
    Project_Name = var.project_name
    Account_ID   = var.account_id
    Region       = var.region
  }
}

resource "aws_iam_access_key" "build_user" {
  user = aws_iam_user.build_user.name
}

resource "aws_iam_user_policy" "build_user" {
  name   = "${var.project_name}-build-user"
  user   = one(aws_iam_user.build_user).name
  policy = var.build_user_iam_policy
}

resource "aws_secretsmanager_secret" "credentials" {
  name = "/image-pipeline/${var.project_name}/build_user_credentials"
}

resource "aws_secretsmanager_secret_version" "credentials" {
  secret_id = aws_secretsmanager_secret.credentials.id
  secret_string = jsonencode({
    aws_secret_access_key = aws_iam_access_key.build_user.secret_id,
    aws_access_key_id     = aws_iam_access_key.build_user.id
  })
}
