# This is a Packer configuration file written in HashiCorp Configuration Language (HCL). 
# Packer is a tool for creating identical machine images for multiple platforms from a single source configuration.

# Here's a breakdown of the key parts:
# Required Plugins: This section specifies the plugins required for this Packer configuration. 
#   It requires the amazon and ansible plugins from HashiCorp.

# Variables: Several variables are defined, such as ansible_roles, project_name, environment, 
#   shared_accounts, source_ami, instance_type, and ssh_username. Some of these variables have default values.

# Data Sources: Two data sources are defined to fetch values from the Amazon Parameter Store. 
#   These values are used to set the region and subnet_id for the Amazon EBS source.

# Source: The source block defines an Amazon EBS source named builder. It uses the variables and 
#   data sources defined earlier to set its properties.

# Build: The build block defines a build named packer-builder that uses the builder source. 
#   It includes two provisioners and a post-processor:

# The shell provisioner runs a shell command to remove a file named ami_id.txt.
# The ansible provisioner runs an Ansible playbook located at ./playbook.yml.
# The shell-local post-processor runs shell commands to write the build name to a 
#   file named ami_id.txt and print the AMI ID.
# This configuration is used to create an Amazon Machine Image (AMI) using Packer. 
#   The AMI is created by launching an EC2 instance of the specified type in the specified region and subnet, 
#   configuring it using Ansible, and then creating an image of the instance. 
#   The ID of the created AMI is written to a file named ami_id.txt.
# Define the required plugins for Packer
packer {
  required_plugins {
    # Amazon plugin for Packer
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
    # Ansible plugin for Packer
    ansible = {
      version = "v1.1.1"
      source ="github.com/hashicorp/ansible"
    }
  }
}

# Define variables for the Packer configuration
variable ansible_roles {
  type = string
}

variable project_name {
  type = string
  default = "daves-awesome-test-ami"
}

variable environment {
  type = string
  default = "dev"
}

variable shared_accounts {
  type = list(string)
  default = []
}

variable "source_ami" {
  description = "The ID of the source AMI"
  default     = "ami-03fadeeea589a106b"
}

variable "instance_type" {
  description = "The type of instance to start"
  default     = "t2.micro"
}

variable "ssh_username" {
  description = "The username to use for SSH to the instance"
  default     = "ec2-user"
}

# Define data sources to fetch values from the Amazon Parameter Store
data "amazon-parameterstore" "region" {
  name = "/image-pipeline/${var.environment}/${var.project_name}/region"
  with_decryption = false
}

data "amazon-parameterstore" "subnets" {
  name = "/image-pipeline/${var.environment}/${var.project_name}/subnets"
  with_decryption = false
}

# Define the Amazon EBS source
source "amazon-ebs" "builder" {
    region        = data.amazon-parameterstore.region.value
    subnet_id     = one(split(",", data.amazon-parameterstore.subnets.value))
    source_ami    = var.source_ami
    instance_type = var.instance_type
    ssh_username  = var.ssh_username
    ami_name      = "${var.ami_name}-${uuidv4()}"
    ami_users     = var.shared_accounts
}

# Define the build
build {
  name    = "packer-builder"
  sources = [
    "source.amazon-ebs.builder"
  ]

  # Provisioner to remove the ami_id.txt file
  provisioner "shell" {
      inline = [
          "rm ami_id.txt || true"
      ]
  }

  # Provisioner to run the Ansible playbook
  provisioner "ansible" {
      playbook_file     = "./playbook.yml"
      roles_path        = var.ansible_roles
      ansible_env_vars  = ["ANSIBLE_STDOUT_CALLBACK=yaml", "ANSIBLE_NOCOLOR=True"]
      user              = var.ssh_username
      extra_arguments   = [
        "-vvv"
      ]
  }
  
  # Post-processor to write the build name to a file and print the AMI ID
  post-processor "shell-local" {
    inline = [
      "echo '{{.BuildName}}' > ami_id.txt",
      "echo 'AMI ID: {{.BuildName}}'"
    ]
  }
}