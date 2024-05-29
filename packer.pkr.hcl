// Define the AWS region
variable "region" {
    description = "AWS Region"
    default     = "us-west-2"
}

// Define the source AMI name
variable "source_ami_name" {
    description = "Source AMI Name"
    default     = "*amzn2-ami-hvm-2.0.2022030*"
}

// Define the name of the AMI that will be created
variable "ami_name" {
    description = "AMI Name"
    default     = "packer-ansible-ami-${local.timestamp}"
}

// Define the AWS account IDs that the AMI will be shared with
variable "shared_accounts" {
    description = "List of AWS account IDs to share the AMI with"
    type        = list(string)
    default     = []
}

// Define the AWS account ID
variable "aws_account_id" {
    description = "AWS Account ID"
    default     = ""
}

// Define the ECR repository
variable "ecr_repository" {
    description = "ECR repository"
    default     = "my-ecr-repo"
}

// Define the Amazon EBS source
source "amazon-ebs" "example" {
    // Set the AWS region
    region = var.region

    // Set the source AMI filter
    source_ami_filter {
        filters = {
            virtualization-type = "hvm"
            name                = var.source_ami_name
            root-device-type    = "ebs"
        }
        // Set the owners to Amazon
        owners      = ["amazon"]
        // Use the most recent AMI
        most_recent = true
    }

    // Set the instance type
    instance_type = "t2.micro"
    // Set the SSH username
    ssh_username  = "ec2-user"
    // Set the name of the AMI that will be created
    ami_name      = var.ami_name
    // Set the AWS account IDs that the AMI will be shared with
    ami_users     = var.shared_accounts
}

// Define the Docker source
source "docker" "example" {
    // Set the base image
    image  = "amazonlinux:2"
    // Commit the changes
    commit = true
}

// Define the Amazon EBS build
build {
    name = "amazon-ebs"
    // Set the sources to the Amazon EBS source
    sources = ["source.amazon-ebs.example"]

    // Define the Ansible provisioner
    provisioner "ansible" {
        // Set the playbook file
        playbook_file = "./playbook.yml"
    }
}

// Define the Docker build
build {
    name = "docker"
    // Set the sources to the Docker source
    sources = ["source.docker.example"]

    // Define the Ansible provisioner
    provisioner "ansible" {
        // Set the playbook file
        playbook_file = "./playbook.yml"
    }

    // Define the Docker tag post-processor
    post-processor "docker-tag" {
        // Set the repository to the ECR repository
        repository = var.ecr_repository
        // Set the tags
        tags       = ["latest"]
    }

    // Define the Docker push post-processor
    post-processor "docker-push" {
        // Enable ECR login
        ecr_login = true
        // Set the AWS access key
        aws_access_key = ""
        // Set the AWS secret key
        aws_secret_key = ""
        // Set the AWS token
        aws_token      = ""
        // Set the login server
        login_server   = "${var.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com"
    }
}