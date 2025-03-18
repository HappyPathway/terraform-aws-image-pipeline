#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

resource "aws_codepipeline" "terraform_pipeline" {

  name     = var.project_name
  role_arn = var.codepipeline_role_arn
  tags     = var.tags

  artifact_store {
    location = var.s3_bucket_name
    type     = "S3"
    encryption_key {
      id   = var.kms_key_arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Download-Pip-Config"
      category         = "Source"
      owner            = "AWS"
      version          = "1"
      provider         = "S3"
      namespace        = "SourcePipConfig"
      output_artifacts = ["SourcePipConfigOutput"]
      run_order        = 1

      configuration = {
        S3Bucket    = var.pip_bucket.name
        S3ObjectKey = var.pip_bucket.key
        PollForSourceChanges = "false"
      }
    }

    action {
      name             = "Download-Packer-Template"
      category         = "Source"
      owner            = "AWS"
      version          = "1"
      provider         = "S3"
      namespace        = "SourceVariables"
      output_artifacts = ["SourceOutput"]
      run_order        = 1

      configuration = {
        S3Bucket    = var.packer_bucket.name
        S3ObjectKey = var.packer_bucket.key
        PollForSourceChanges = "false"
      }
    }

    action {
      name             = "Download-Ansible-Roles"
      category         = "Source"
      owner            = "AWS"
      version          = "1"
      provider         = "S3"
      namespace        = "SourceAnsible"
      output_artifacts = ["SourceAnsibleOutput"]
      run_order        = 1

      configuration = {
        S3Bucket    = var.ansible_bucket.name
        S3ObjectKey = var.ansible_bucket.key
        PollForSourceChanges = "false"
      }  
    }

    action {
      name             = "Download-Goss-Testing-Suite"
      category         = "Source"
      owner            = "AWS"
      version          = "1"
      provider         = "S3"
      namespace        = "SourceGoss"
      output_artifacts = ["SourceGossOutput"]
      run_order        = 1

      configuration = {
        S3Bucket    = var.goss_bucket.name
        S3ObjectKey = var.goss_bucket.key
        PollForSourceChanges = "false"
      }
    }
  }

  dynamic "stage" {
    for_each = local.stages

    content {
      name = title(stage.value["name"])
      action {
        category         = stage.value["category"]
        name             = "${var.project_name}-${stage.value["name"]}"
        owner            = stage.value["owner"]
        provider         = stage.value["provider"]
        input_artifacts  = lookup(stage.value, "input_artifacts", "") != "" ? stage.value["input_artifacts"] : null
        output_artifacts = lookup(stage.value, "output_artifacts", "") != "" ? stage.value["output_artifacts"] : null
        version          = "1"
        run_order        = index(local.stages, stage.value) + 2

        configuration = {
          ProjectName   = "${var.project_name}-${stage.value["name"]}"
          PrimarySource = "SourceOutput"
        }
      }
    }
  }

}
