resource "aws_iam_policy" "policy" {
  count       = var.vpc_config == null ? 0 : 1
  name        = "${var.project_name}-vpc-access"
  path        = "/"
  description = "${var.project_name}-vpc-access"
  policy = jsonencode({
    Version =  "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterfacePermission"
        ]
        Resource = "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:network-interface/*",
        Condition = {
          StringEquals = {
            "ec2:AuthorizedService": "codebuild.amazonaws.com"
          }
          ArnEquals = {
            "ec2:Subnet": [
              for subnet in var.vpc_config.subnets : "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:subnet/${subnet}"
            ]
          }
        }
      }
    ]
  })
}
