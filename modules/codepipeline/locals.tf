locals {
  build_sources = ["SourceOutput", "SourceAnsibleOutput", "SourcePipConfigOutput"]
  test_sources  = ["SourceOutput", "SourceGossOutput"]
  stages = [
    {
      name             = "build",
      category         = "Build",
      owner            = "AWS",
      provider         = "CodeBuild",
      input_artifacts  = local.build_sources,
      output_artifacts = ["BuildOutput"]
    },
    {
      name             = "test",
      category         = "Build",
      owner            = "AWS",
      provider         = "CodeBuild",
      input_artifacts  = local.test_sources,
      output_artifacts = ["BuildTestOutput"]
    },
  ]
}