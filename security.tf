resource "aws_security_group" "this" {
  name        = "${var.cluster_name}-sg"
  description = "Security group for Aurora cluster ${var.cluster_name}"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "from_security_groups" {
  for_each = toset(var.inbound_sg_permitted)

  security_group_id            = aws_security_group.this.id
  description                  = "Allow PostgreSQL traffic from ${each.value}"
  from_port                    = var.port
  to_port                      = var.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = each.value

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "from_cidr_blocks" {
  for_each = toset(var.inbound_cidr_permitted)

  security_group_id = aws_security_group.this.id
  description       = "Allow PostgreSQL traffic from ${each.value}"
  from_port         = var.port
  to_port           = var.port
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value

  tags = var.tags
}

resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.this.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = var.tags
}
