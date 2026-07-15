resource "aws_db_subnet_group" "main" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.name}-sg"
  description = "Access to ${var.name} database"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.from_port
    to_port     = var.from_port
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_db_parameter_group" "rds_pg" {
  count  = var.use_aurora ? 0 : 1
  name   = "${var.name}-rds-pg"
  family = var.rds_parameter_group_family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.key
      value        = parameter.value
      apply_method = "pending-reboot"
    }
  }

  tags = var.tags
}

resource "aws_rds_cluster_parameter_group" "aurora_pg" {
  count  = var.use_aurora ? 1 : 0
  name   = "${var.name}-aurora-pg"
  family = var.aurora_parameter_group_family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.key
      value        = parameter.value
      apply_method = "pending-reboot"
    }
  }

  tags = var.tags
}
