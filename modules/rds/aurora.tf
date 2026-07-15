resource "aws_rds_cluster" "aurora" {
  count                           = var.use_aurora ? 1 : 0
  cluster_identifier              = var.name
  engine                          = var.aurora_engine
  engine_version                  = var.aurora_engine_version
  master_username                 = var.username
  master_password                 = var.password
  database_name                   = var.db_name
  db_subnet_group_name            = aws_db_subnet_group.main.name
  vpc_security_group_ids          = [aws_security_group.rds_sg.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_pg[0].name
  skip_final_snapshot             = true
  backup_retention_period         = var.backup_retention_period
  tags                            = var.tags
}

resource "aws_rds_cluster_instance" "aurora_instances" {
  count              = var.use_aurora ? var.aurora_instance_count : 0
  identifier         = "${var.name}-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.aurora[0].id
  instance_class     = var.instance_class
  engine             = var.aurora_engine
  tags               = var.tags
}
