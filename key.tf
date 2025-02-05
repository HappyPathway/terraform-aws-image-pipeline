resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "random_pet" "keyname" {
  keepers = {
    project = var.project_name
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-deployer-key-${random_pet.keyname.id}"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "aws_secretsmanager_secret" "ssh_key" {
  name = "/image-pipeline/${var.project_name}/ssh-private-key"
}

resource "aws_secretsmanager_secret_version" "ssh_key" {
  secret_id     = aws_secretsmanager_secret.ssh_key.id
  secret_string = tls_private_key.ssh.private_key_pem
}
