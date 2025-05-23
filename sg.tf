/* -------------------------------------------------------------------------- */
/*                          SERVER  SECURITY GROUP                            */
/* -------------------------------------------------------------------------- */
resource "aws_security_group" "server" {
  count = var.is_create_cluster && var.is_create_security_group ? 1 : 0

  name        = "${local.name}-cluster-sg"
  vpc_id      = var.vpc_id
  description = coalesce(var.security_group_description, "Control traffic to/from RDS Aurora ${var.name}")

  tags = merge(local.tags, { "Name" = "${local.name}-cluster-sg" })
}

resource "aws_security_group_rule" "ingress" {
  for_each = var.is_create_cluster && var.is_create_security_group ? var.security_group_ingress_rules : null

  type                     = "ingress"
  from_port                = lookup(each.value, "from_port", local.port)
  to_port                  = lookup(each.value, "to_port", local.port)
  protocol                 = lookup(each.value, "protocol", "tcp")
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
  security_group_id        = local.rds_security_group_id
  description              = lookup(each.value, "description", null)
}

resource "aws_security_group_rule" "from_client" {
  count             = var.is_create_cluster && var.is_create_security_group ? 1 : 0
  type              = "ingress"
  from_port         = local.port
  to_port           = local.port
  protocol          = "tcp"
  security_group_id = local.rds_security_group_id
  description       = "Ingress rule for allow traffic from rds client security group"

  source_security_group_id = local.rds_client_security_group_id
}

resource "aws_security_group_rule" "egress" {
  for_each = var.is_create_cluster && var.is_create_security_group ? var.security_group_egress_rules : null

  # required
  type              = "egress"
  from_port         = lookup(each.value, "from_port", local.port)
  to_port           = lookup(each.value, "to_port", local.port)
  protocol          = lookup(each.value, "protocol", "tcp")
  security_group_id = local.rds_security_group_id

  # optional
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  description              = lookup(each.value, "description", null)
  ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null)
  prefix_list_ids          = lookup(each.value, "prefix_list_ids", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
}


/* -------------------------------------------------------------------------- */
/*                               SECURITY_GROUP_CLIENT                        */
/* -------------------------------------------------------------------------- */
resource "aws_security_group" "client" {
  count       = var.is_create_cluster && var.is_create_security_group ? 1 : 0
  name        = "${local.name}-client-sg"
  description = "Security group for the ${local.name} DB client"
  vpc_id      = var.vpc_id

  tags = merge(local.tags, { "Name" : "${local.name}-client-sg" })
}

# Security group rule for outgoing to cluster connections
resource "aws_security_group_rule" "to_cluster" {
  count             = var.is_create_cluster && var.is_create_security_group ? 1 : 0
  type              = "egress"
  from_port         = local.port
  to_port           = local.port
  protocol          = "tcp"
  security_group_id = local.rds_client_security_group_id
  description       = "Egress rule for allow traffic to rds cluster security group"

  source_security_group_id = local.rds_security_group_id
}