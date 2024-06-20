resource "aws_security_group" "packer" {
  count       = var.vpc_config == null ? 0 : 1
  name        = "${var.project_name}-packer-builder"
  description = "Packer Network Access"
  vpc_id      = var.vpc_config.vpc_id
  tags = {
    Name = "packer_builder"
  }
}

resource "aws_security_group_rule" "sg_rule" {
  count                    = var.vpc_config == null ? 0 : 1
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = one(aws_security_group.packer).id
  source_security_group_id = one(aws_security_group.packer).id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  count             = var.vpc_config == null ? 0 : 1
  security_group_id = one(aws_security_group.packer).id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_ssh_ipv4" {
  count             = var.vpc_config == null ? 0 : 1
  security_group_id = one(aws_security_group.packer).id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  count             = var.vpc_config == null ? 0 : 1
  security_group_id = one(aws_security_group.packer).id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

locals {
  vpc_config = var.vpc_config != null ? merge(
    var.vpc_config,
    {
      security_group_ids = concat(var.vpc_config.security_group_ids, [one(aws_security_group.packer).id])
    }
  ) : null
}