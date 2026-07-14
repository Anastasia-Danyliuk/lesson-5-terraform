resource "aws_db_subnet_group" "main" {
  name       = "final-project-db-subnets"
  subnet_ids = var.subnet_ids

  tags = { Name = "final-project-db-subnets" }
}

resource "aws_security_group" "rds" {
  name        = "final-project-rds-sg"
  description = "PostgreSQL access from the private VPC network"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "final-project-rds-sg" }
}

resource "aws_db_instance" "postgres" {
  identifier              = "final-project-postgres"
  engine                  = "postgres"
  engine_version          = "16.4"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  max_allocated_storage   = 50
  storage_type            = "gp3"
  storage_encrypted       = true
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  port                    = 5432
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  publicly_accessible     = false
  multi_az                = false
  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false
  apply_immediately       = true

  tags = { Name = "final-project-postgres" }
}
