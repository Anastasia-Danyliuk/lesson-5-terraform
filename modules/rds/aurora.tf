resource "aws_rds_cluster" "aurora" {
  count                  = var.use_aurora ? 1 : 0
  cluster_identifier     = "aurora-cluster"
  engine                 = "aurora-postgresql"
  engine_version         = "14"
  master_password        = var.password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_pg[0].name
  skip_final_snapshot    = true
}

resource "aws_rds_cluster_instance" "aurora_instances" {
  count              = var.use_aurora ? 1 : 0
  identifier         = "aurora-instance"
  cluster_identifier = aws_rds_cluster.aurora[0].id
  instance_class     = var.instance_class
  engine             = "aurora-postgresql"
}