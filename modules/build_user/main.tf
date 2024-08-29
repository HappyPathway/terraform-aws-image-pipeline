resource "aws_iam_user" "build_user" {
  // Create an IAM user for the build process
  name = var.project_name
  path = "/tf-pipeline/"
  tags = {
    Project_Name = var.project_name // Tag the user with the project name
    Account_ID   = var.account_id   // Tag the user with the account ID
    Region       = var.region       // Tag the user with the region
  }
}

resource "aws_iam_access_key" "build_user" {
  // Create an access key for the build user
  user = aws_iam_user.build_user.name
}

resource "aws_iam_user_policy" "build_user" {
  // Attach a policy to the build user
  name   = "${var.project_name}-build-user"
  user   = one(aws_iam_user.build_user).name
  policy = var.build_user_iam_policy
}

resource "aws_secretsmanager_secret" "credentials" {
  // Create a Secrets Manager secret to store the build user's credentials
  name = "/image-pipeline/${var.project_name}/build_user_credentials"
}

resource "aws_secretsmanager_secret_version" "credentials" {
  // Store the build user's access key and secret key in the Secrets Manager secret
  secret_id = aws_secretsmanager_secret.credentials.id
  secret_string = jsonencode({
    aws_secret_access_key = aws_iam_access_key.build_user.secret_id,
    aws_access_key_id     = aws_iam_access_key.build_user.id
  })
}
