locals {
  role_arn = var.create_new_role ? aws_iam_role.codepipeline_role[0].arn : data.aws_iam_role.existing_codepipeline_role[0].arn
}