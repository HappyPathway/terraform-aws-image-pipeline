
[![Terraform Validation](https://github.com/HappyPathway/terraform-aws-image-pipeline/actions/workflows/terraform.yaml/badge.svg)](https://github.com/HappyPathway/terraform-aws-image-pipeline/actions/workflows/terraform.yaml)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.20.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.91.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.1 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.6 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_build_user"></a> [build\_user](#module\_build\_user) | ./modules/build_user | n/a |
| <a name="module_codebuild_terraform"></a> [codebuild\_terraform](#module\_codebuild\_terraform) | ./modules/codebuild | n/a |
| <a name="module_codepipeline_iam_role"></a> [codepipeline\_iam\_role](#module\_codepipeline\_iam\_role) | ./modules/iam-role | n/a |
| <a name="module_codepipeline_kms"></a> [codepipeline\_kms](#module\_codepipeline\_kms) | ./modules/kms | n/a |
| <a name="module_codepipeline_terraform"></a> [codepipeline\_terraform](#module\_codepipeline\_terraform) | ./modules/codepipeline | n/a |
| <a name="module_s3_artifacts_bucket"></a> [s3\_artifacts\_bucket](#module\_s3\_artifacts\_bucket) | ./modules/s3 | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.build_user_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.build_user_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.build_user_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_key_pair.deployer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_secretsmanager_secret.secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.ssh_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.ssh_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.packer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.sg_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ssm_parameter.managed_parameters](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_vpc_security_group_egress_rule.allow_all_traffic_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.allow_all_traffic_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allow_all_ssh_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [random_pet.keyname](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.build_user_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | n/a | <pre>object({<br>    instance_type = string<br>    source_ami    = string<br>  })</pre> | `null` | no |
| <a name="input_ansible_bucket"></a> [ansible\_bucket](#input\_ansible\_bucket) | Ansible bucket details | <pre>object({<br>    name = string,<br>    key  = string,<br>    arn  = string<br>  })</pre> | `null` | no |
| <a name="input_assets_bucket_name"></a> [assets\_bucket\_name](#input\_assets\_bucket\_name) | Name of the S3 bucket used to store the deployment artifacts | `string` | `"image-pipeline-assets"` | no |
| <a name="input_build_environment_variables"></a> [build\_environment\_variables](#input\_build\_environment\_variables) | n/a | <pre>list(object({<br>    name  = string<br>    value = string<br>    type  = optional(string, "PLAINTEXT")<br>  }))</pre> | `null` | no |
| <a name="input_build_project_source"></a> [build\_project\_source](#input\_build\_project\_source) | Source Code Repo for Playbook | `string` | `"CODEPIPELINE"` | no |
| <a name="input_build_projects"></a> [build\_projects](#input\_build\_projects) | List of Names of the CodeBuild projects to be created | <pre>list(object({<br>    name = string,<br>    vars = optional(map(string), {})<br>    environment_variables = optional(list(object({<br>      name  = string<br>      value = string<br>      type  = string<br>    })), [])<br>    buildspec = optional(string)<br>  }))</pre> | <pre>[<br>  {<br>    "name": "build"<br>  },<br>  {<br>    "name": "test"<br>  }<br>]</pre> | no |
| <a name="input_build_user_iam_policy"></a> [build\_user\_iam\_policy](#input\_build\_user\_iam\_policy) | The IAM policy for the build user. | `string` | `null` | no |
| <a name="input_builder_compute_type"></a> [builder\_compute\_type](#input\_builder\_compute\_type) | Relative path to the Apply and Destroy build spec file | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| <a name="input_builder_image"></a> [builder\_image](#input\_builder\_image) | Docker Image to be used by codebuild | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:3.0"` | no |
| <a name="input_builder_image_pull_credentials_type"></a> [builder\_image\_pull\_credentials\_type](#input\_builder\_image\_pull\_credentials\_type) | Image pull credentials type used by codebuild project | `string` | `"CODEBUILD"` | no |
| <a name="input_builder_images"></a> [builder\_images](#input\_builder\_images) | n/a | `map(string)` | `{}` | no |
| <a name="input_builder_type"></a> [builder\_type](#input\_builder\_type) | Type of codebuild run environment | `string` | `"LINUX_CONTAINER"` | no |
| <a name="input_codepipeline_iam_role_name"></a> [codepipeline\_iam\_role\_name](#input\_codepipeline\_iam\_role\_name) | Name of the IAM role to be used by the Codepipeline | `string` | `"codepipeline-role"` | no |
| <a name="input_create_build_user"></a> [create\_build\_user](#input\_create\_build\_user) | Whether to create a build user. Set to false if you want to use an existing user. | `bool` | `true` | no |
| <a name="input_create_new_role"></a> [create\_new\_role](#input\_create\_new\_role) | Whether to create a new IAM Role. Values are true or false. Defaulted to true always. | `bool` | `true` | no |
| <a name="input_docker_build"></a> [docker\_build](#input\_docker\_build) | n/a | `bool` | `false` | no |
| <a name="input_extra_parameters"></a> [extra\_parameters](#input\_extra\_parameters) | n/a | `map(string)` | `{}` | no |
| <a name="input_goss_binary"></a> [goss\_binary](#input\_goss\_binary) | GOSS Profile to be used for testing | `string` | `"goss-linux-amd64"` | no |
| <a name="input_goss_bucket"></a> [goss\_bucket](#input\_goss\_bucket) | Goss bucket details | <pre>object({<br>    name = string,<br>    key  = string,<br>  })</pre> | `null` | no |
| <a name="input_goss_profile"></a> [goss\_profile](#input\_goss\_profile) | GOSS Profile to be used for testing | `string` | `"goss"` | no |
| <a name="input_image"></a> [image](#input\_image) | n/a | <pre>object({<br>    dest_tag           = string<br>    dest_docker_repo   = string<br>    source_image       = string<br>    source_tag         = string<br>    source_docker_repo = string<br>  })</pre> | `null` | no |
| <a name="input_image_volume_mapping"></a> [image\_volume\_mapping](#input\_image\_volume\_mapping) | n/a | <pre>list(object({<br>    device_name           = string<br>    volume_size           = number<br>    volume_type           = string<br>    delete_on_termination = bool<br>    encrypted             = optional(bool, false)<br>    iops                  = optional(number, null)<br>    snapshot_id           = optional(string, null)<br>    throughput            = optional(number, null)<br>    virtual_name          = optional(string, null)<br>    kms_key_id            = optional(string, null)<br>    mount_path            = optional(string, null)<br>  }))</pre> | `[]` | no |
| <a name="input_instance_profile"></a> [instance\_profile](#input\_instance\_profile) | n/a | `string` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | n/a | `string` | `null` | no |
| <a name="input_nonmanaged_parameters"></a> [nonmanaged\_parameters](#input\_nonmanaged\_parameters) | n/a | `list(string)` | <pre>[<br>  "dest_tag"<br>]</pre> | no |
| <a name="input_packer_bucket"></a> [packer\_bucket](#input\_packer\_bucket) | Source bucket details | <pre>object({<br>    name = string,<br>    arn  = string,<br>    key  = string<br>  })</pre> | `null` | no |
| <a name="input_packer_config"></a> [packer\_config](#input\_packer\_config) | Name of Packer Config in Repo | `string` | `"build.pkr.hcl"` | no |
| <a name="input_packer_version"></a> [packer\_version](#input\_packer\_version) | Terraform CLI Version | `string` | `"1.10.3"` | no |
| <a name="input_parameter_arns"></a> [parameter\_arns](#input\_parameter\_arns) | n/a | `list(string)` | `null` | no |
| <a name="input_pip_bucket"></a> [pip\_bucket](#input\_pip\_bucket) | Goss bucket details | <pre>object({<br>    name = string,<br>    key  = string,<br>  })</pre> | `null` | no |
| <a name="input_playbook"></a> [playbook](#input\_playbook) | n/a | `string` | `null` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Unique name for this project | `string` | n/a | yes |
| <a name="input_required_packages"></a> [required\_packages](#input\_required\_packages) | n/a | <pre>list(object({<br>    src  = string<br>    dest = string<br>  }))</pre> | `[]` | no |
| <a name="input_secret_arns"></a> [secret\_arns](#input\_secret\_arns) | n/a | `list(string)` | `null` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | n/a | `map(string)` | `{}` | no |
| <a name="input_shared_accounts"></a> [shared\_accounts](#input\_shared\_accounts) | n/a | `list(string)` | `null` | no |
| <a name="input_shared_kms_key_arns"></a> [shared\_kms\_key\_arns](#input\_shared\_kms\_key\_arns) | n/a | `list(string)` | `[]` | no |
| <a name="input_ssh_user"></a> [ssh\_user](#input\_ssh\_user) | SSH username | `string` | `null` | no |
| <a name="input_state"></a> [state](#input\_state) | n/a | <pre>object({<br>    bucket         = string<br>    key            = string<br>    region         = string<br>    dynamodb_table = string<br>  })</pre> | n/a | yes |
| <a name="input_terraform_version"></a> [terraform\_version](#input\_terraform\_version) | n/a | `string` | `"1.3.10"` | no |
| <a name="input_test_project_source"></a> [test\_project\_source](#input\_test\_project\_source) | Source Code Repo for Goss Testing Suite | `string` | `"CODEPIPELINE"` | no |
| <a name="input_troubleshoot"></a> [troubleshoot](#input\_troubleshoot) | n/a | `bool` | `false` | no |
| <a name="input_userdata"></a> [userdata](#input\_userdata) | n/a | `string` | `null` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | n/a | <pre>object({<br>    security_group_ids = list(string)<br>    subnets            = list(string)<br>    vpc_id             = string<br>    region             = string<br>  })</pre> | `null` | no |
| <a name="input_winrm_credentials"></a> [winrm\_credentials](#input\_winrm\_credentials) | n/a | <pre>object({<br>    username = string<br>    password = string<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codepipeline_arn"></a> [codepipeline\_arn](#output\_codepipeline\_arn) | The ARN of the CodePipeline |
| <a name="output_codepipeline_name"></a> [codepipeline\_name](#output\_codepipeline\_name) | The Name of the CodePipeline |
| <a name="output_iam_arn"></a> [iam\_arn](#output\_iam\_arn) | The ARN of the IAM Role used by the CodePipeline |
| <a name="output_kms_arn"></a> [kms\_arn](#output\_kms\_arn) | The KMS key ARN used in the codepipeline |
| <a name="output_managed_parameters"></a> [managed\_parameters](#output\_managed\_parameters) | n/a |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | The name of the IAM role used for build and pipeline operations |
| <a name="output_s3_arn"></a> [s3\_arn](#output\_s3\_arn) | The ARN of the S3 Bucket |
| <a name="output_s3_bucket"></a> [s3\_bucket](#output\_s3\_bucket) | The Name of the S3 Bucket |
| <a name="output_sec_group"></a> [sec\_group](#output\_sec\_group) | n/a |
| <a name="output_secrets"></a> [secrets](#output\_secrets) | n/a |
<!-- END_TF_DOCS -->