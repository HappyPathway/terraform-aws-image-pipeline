# AWS CodePipeline CI/CD example
Terraform is an infrastructure-as-code (IaC) tool that helps you create, update, and version your infrastructure in a secure and repeatable manner.

The scope of this pattern is to provide a guide and ready to use terraform configurations to setup validation pipelines with end-to-end tests based on AWS CodePipeline, AWS CodeBuild, AWS CodeCommit and Terraform. 

The created pipeline uses the best practices for infrastructure validation and has the below stages

- validate - This stage focuses on terraform IaC validation tools and commands such as terraform validate, terraform format, tfsec, tflint and checkov
- plan - This stage creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure.
- apply - This stage uses the plan created above to provision the infrastructure in the test account.
- destroy - This stage destroys the infrastructure created in the above stage.
Running these four stages ensures the integrity of the terraform configurations.

## Directory Structure
```shell
|-- CODE_OF_CONDUCT.md
|-- CONTRIBUTING.md
|-- LICENSE
|-- README.md
|-- data.tf
|-- examples
|   `-- terraform.tfvars
|-- locals.tf
|-- main.tf
|-- modules
|   |-- codebuild
|   |   |-- README.md
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   |-- codecommit
|   |   |-- README.md
|   |   |-- data.tf
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   |-- codepipeline
|   |   |-- README.md
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   |-- iam-role
|   |   |-- README.md
|   |   |-- data.tf
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   |-- kms
|   |   |-- README.md
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   `-- s3
|       |-- README.md
|       |-- main.tf
|       |-- outputs.tf
|       `-- variables.tf
|-- templates
|   |-- buildspec_apply.yml
|   |-- buildspec_destroy.yml
|   |-- buildspec_plan.yml
|   |-- buildspec_validate.yml
|   `-- scripts
|       `-- tf_ssp_validation.sh
`-- variables.tf

```
## Installation

#### Step 1: Clone this repository.

```shell
git@github.com:HappyPathway/terraform-aws-image-pipeline.git
```
Note: If you don't have git installed, [install git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).


#### Step 2: Update the variables in `examples/terraform.tfvars` based on your requirement. Make sure you ae updating the variables project_name, environment, packer_repo_name, packer_repo_branch, create_new_repo, stage_input and build_projects.

- If you are planning to use an existing terraform CodeCommit repository, then update the variable create_new_repo as false and provide the name of your existing repo under the variable packer_repo_name
- If you are planning to create new terraform CodeCommit repository, then update the variable create_new_repo as true and provide the name of your new repo under the variable packer_repo_name

#### Step 3: Update remote backend configuration as required

#### Step 4: Configure the AWS Command Line Interface (AWS CLI) where this IaC is being executed. For more information, see [Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).

#### Step 5: Initialize the directory. Run terraform init

#### Step 6: Start a Terraform run using the command terraform apply

Note: Sample terraform.tfvars are available in the examples directory. You may use the below command if you need to provide this sample tfvars as an input to the apply command.
```shell
terraform apply -var-file=./examples/terraform.tfvars
```

## Pre-Requisites

#### Step 1: You would get packer_repo_clone_url_http as an output of the installation step. Clone the repository to your local.

git clone <packer_repo_clone_url_http>

#### Step 2: Clone this repository.

```shell
git@github.com:aws-samples/aws-eks-accelerator-for-terraform.git
```
Note: If you don't have git installed, [install git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).

#### Step 3: Copy the templates folder to the AWS CodeCommit sourcecode repository which contains the terraform code to be deployed.
```shell
cd examples/ci-cd/aws-codepipeline
cp -r templates $YOUR_CODECOMMIT_REPO_ROOT
```


#### Step 4: Update the variables in the template files with appropriate values and push the same.

#### Step 5: Trigger the pipeline created in the Installation step.

**Note1**: The IAM Role used by the newly created pipeline is very restrictive and follows the Principle of least privilege. Please update the IAM Policy with the required permissions. 
Alternatively, use the _**create_new_role = false**_ option to use an existing IAM role and specify the role name using the variable _**codepipeline_iam_role_name**_

**Note2**: If the **create_new_repo** flag is set to **true**, a new blank repository will be created with the name assigned to the variable **_packer_repo_name_**. Since this repository will not be containing the templates folder specified in Step 3 nor any code files, the initial run of the pipeline will be marked as failed in the _Download-Source_ stage itself.

**Note3**: If the **create_new_repo** flag is set to **false** to use an existing repository, ensure the pre-requisite steps specified in step 3 have been done on the target repository.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.20.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.49.0 |

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
| [aws_secretsmanager_secret.secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.packer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.sg_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ssm_parameter.managed_parameters](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.nonmanaged_parameters](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_vpc_security_group_egress_rule.allow_all_traffic_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.allow_all_traffic_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allow_all_ssh_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.build_user_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | n/a | <pre>object({<br>    instance_type = string<br>    source_ami    = string<br>  })</pre> | `null` | no |
| <a name="input_ansible_bucket"></a> [ansible\_bucket](#input\_ansible\_bucket) | Ansible bucket details | <pre>object({<br>    name = string,<br>    key  = string<br>  })</pre> | `null` | no |
| <a name="input_ansible_repo"></a> [ansible\_repo](#input\_ansible\_repo) | Source of Ansible Repo | <pre>object({<br>    arn             = optional(string)<br>    repository_name = optional(string, "image-pipeline-ansible-playbooks")<br>    branch          = optional(string, "main")<br>  })</pre> | `null` | no |
| <a name="input_ansible_source_type"></a> [ansible\_source\_type](#input\_ansible\_source\_type) | Type of source to be used for the Ansible CodePipeline | `string` | `"CodeCommit"` | no |
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
| <a name="input_create_new_role"></a> [create\_new\_role](#input\_create\_new\_role) | Whether to create a new IAM Role. Values are true or false. Defaulted to true always. | `bool` | `true` | no |
| <a name="input_docker_test_enabled"></a> [docker\_test\_enabled](#input\_docker\_test\_enabled) | n/a | `bool` | `false` | no |
| <a name="input_extra_parameters"></a> [extra\_parameters](#input\_extra\_parameters) | n/a | `map(string)` | `{}` | no |
| <a name="input_goss_binary"></a> [goss\_binary](#input\_goss\_binary) | GOSS Profile to be used for testing | `string` | `"goss-linux-amd64"` | no |
| <a name="input_goss_bucket"></a> [goss\_bucket](#input\_goss\_bucket) | Goss bucket details | <pre>object({<br>    name = string,<br>    key  = string<br>  })</pre> | `null` | no |
| <a name="input_goss_profile"></a> [goss\_profile](#input\_goss\_profile) | GOSS Profile to be used for testing | `string` | `"goss"` | no |
| <a name="input_goss_repo"></a> [goss\_repo](#input\_goss\_repo) | Source of Goss Repo | <pre>object({<br>    arn             = optional(string)<br>    repository_name = optional(string, "image-pipeline-goss-testing")<br>    branch          = optional(string, "main")<br>  })</pre> | `null` | no |
| <a name="input_goss_source_type"></a> [goss\_source\_type](#input\_goss\_source\_type) | Type of source to be used for the Goss CodePipeline | `string` | `"CodeCommit"` | no |
| <a name="input_image"></a> [image](#input\_image) | n/a | <pre>object({<br>    dest_tag           = string<br>    dest_docker_repo   = string<br>    source_image       = string<br>    source_tag         = string<br>    source_docker_repo = string<br>  })</pre> | `null` | no |
| <a name="input_nonmanaged_parameters"></a> [nonmanaged\_parameters](#input\_nonmanaged\_parameters) | n/a | `list(string)` | <pre>[<br>  "dest_tag"<br>]</pre> | no |
| <a name="input_packer_bucket"></a> [packer\_bucket](#input\_packer\_bucket) | Source bucket details | <pre>object({<br>    name = string,<br>    key  = string<br>  })</pre> | `null` | no |
| <a name="input_packer_config"></a> [packer\_config](#input\_packer\_config) | Name of Packer Config in Repo | `string` | `"build.pkr.hcl"` | no |
| <a name="input_packer_repo"></a> [packer\_repo](#input\_packer\_repo) | Source of the Terraform Repo | <pre>object({<br>    arn             = optional(string)<br>    repository_name = optional(string, "linux-image-pipeline")<br>    branch          = optional(string, "main")<br>  })</pre> | `null` | no |
| <a name="input_packer_source_type"></a> [packer\_source\_type](#input\_packer\_source\_type) | Type of source to be used for the CodePipeline | `string` | `"CodeCommit"` | no |
| <a name="input_packer_version"></a> [packer\_version](#input\_packer\_version) | Terraform CLI Version | `string` | `"1.10.3"` | no |
| <a name="input_parameter_arns"></a> [parameter\_arns](#input\_parameter\_arns) | n/a | `list(string)` | `null` | no |
| <a name="input_playbook"></a> [playbook](#input\_playbook) | n/a | `string` | `null` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Unique name for this project | `string` | n/a | yes |
| <a name="input_secret_arns"></a> [secret\_arns](#input\_secret\_arns) | n/a | `list(string)` | `null` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | n/a | `map(string)` | `{}` | no |
| <a name="input_shared_accounts"></a> [shared\_accounts](#input\_shared\_accounts) | n/a | `list(string)` | `null` | no |
| <a name="input_ssh_user"></a> [ssh\_user](#input\_ssh\_user) | SSH username | `string` | `null` | no |
| <a name="input_stage_input"></a> [stage\_input](#input\_stage\_input) | Tags to be attached to the CodePipeline | <pre>list(object({<br>    name             = string,<br>    category         = string,<br>    owner            = string,<br>    provider         = string,<br>    input_artifacts  = list(string),<br>    output_artifacts = list(string)<br>  }))</pre> | <pre>[<br>  {<br>    "category": "Build",<br>    "input_artifacts": [<br>      "SourceOutput",<br>      "SourceAnsibleOutput"<br>    ],<br>    "name": "build",<br>    "output_artifacts": [<br>      "BuildOutput"<br>    ],<br>    "owner": "AWS",<br>    "provider": "CodeBuild"<br>  },<br>  {<br>    "category": "Build",<br>    "input_artifacts": [<br>      "SourceOutput",<br>      "SourceGossOutput"<br>    ],<br>    "name": "test",<br>    "output_artifacts": [<br>      "BuildTestOutput"<br>    ],<br>    "owner": "AWS",<br>    "provider": "CodeBuild"<br>  }<br>]</pre> | no |
| <a name="input_state"></a> [state](#input\_state) | n/a | <pre>object({<br>    bucket         = string<br>    key            = string<br>    region         = string<br>    dynamodb_table = string<br>  })</pre> | n/a | yes |
| <a name="input_terraform_version"></a> [terraform\_version](#input\_terraform\_version) | n/a | `string` | `"1.3.10"` | no |
| <a name="input_test_project_source"></a> [test\_project\_source](#input\_test\_project\_source) | Source Code Repo for Goss Testing Suite | `string` | `"CODEPIPELINE"` | no |
| <a name="input_troubleshoot"></a> [troubleshoot](#input\_troubleshoot) | n/a | `bool` | `false` | no |
| <a name="input_userdata"></a> [userdata](#input\_userdata) | n/a | `string` | `null` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | n/a | <pre>object({<br>    security_group_ids = list(string)<br>    subnets            = list(string)<br>    vpc_id             = string<br>    region             = string<br>  })</pre> | `null` | no |
| <a name="input_vpc_services"></a> [vpc\_services](#input\_vpc\_services) | n/a | `list(string)` | <pre>[<br>  "codecommit",<br>  "git-codecommit",<br>  "s3",<br>  "ecr.dkr",<br>  "ecr.api"<br>]</pre> | no |
| <a name="input_winrm_credentials"></a> [winrm\_credentials](#input\_winrm\_credentials) | n/a | <pre>object({<br>    username = string<br>    password = string<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codepipeline_arn"></a> [codepipeline\_arn](#output\_codepipeline\_arn) | The ARN of the CodePipeline |
| <a name="output_codepipeline_name"></a> [codepipeline\_name](#output\_codepipeline\_name) | The Name of the CodePipeline |
| <a name="output_iam_arn"></a> [iam\_arn](#output\_iam\_arn) | The ARN of the IAM Role used by the CodePipeline |
| <a name="output_kms_arn"></a> [kms\_arn](#output\_kms\_arn) | The ARN of the KMS key used in the codepipeline |
| <a name="output_managed_parameters"></a> [managed\_parameters](#output\_managed\_parameters) | n/a |
| <a name="output_nonmanaged_parameters"></a> [nonmanaged\_parameters](#output\_nonmanaged\_parameters) | n/a |
| <a name="output_s3_arn"></a> [s3\_arn](#output\_s3\_arn) | The ARN of the S3 Bucket |
| <a name="output_s3_bucket"></a> [s3\_bucket](#output\_s3\_bucket) | The Name of the S3 Bucket |
| <a name="output_sec_group"></a> [sec\_group](#output\_sec\_group) | n/a |
| <a name="output_secrets"></a> [secrets](#output\_secrets) | n/a |
<!-- END_TF_DOCS -->

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

