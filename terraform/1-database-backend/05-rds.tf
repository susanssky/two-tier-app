resource "aws_db_subnet_group" "subnet_group" {
  # for RDS
  name       = "${local.project_name}-rds-subnet-group"
  subnet_ids = [for id in aws_subnet.private[*].id : id]
  tags = {
    Name = "${local.project_name}-rds-subnet-group"
  }
}
resource "aws_db_parameter_group" "parameter_group" {
  name   = "${local.project_name}-rds-parameter-group"
  family = "postgres16"
  tags = {
    Name = "${local.project_name}-rds-parameter-group"
  }
}

resource "aws_db_instance" "database" {
  db_subnet_group_name     = aws_db_subnet_group.subnet_group.id //If unspecified, will be created in the default VPC, or in EC2 Classic
  vpc_security_group_ids   = [aws_security_group.rds.id]
  allocated_storage        = 20
  identifier               = "${local.project_name}-db"
  engine                   = "postgres"
  engine_version           = 16.3
  instance_class           = "db.t3.micro"
  username                 = var.database_username
  password                 = var.database_password
  port                     = 5432
  publicly_accessible      = false
  delete_automated_backups = false
  multi_az                 = false
  parameter_group_name     = aws_db_parameter_group.parameter_group.name
  availability_zone        = data.aws_availability_zones.available.names[0]
  skip_final_snapshot      = true //Determines if a snapshot should be taken before deleting the database. The database can be created without setting this setting. However, while destroying this database instance using Terraform, if this value is not set to true, the database is not destroyed.
  tags = {
    Name = "${local.project_name}-rds"
  }
}
