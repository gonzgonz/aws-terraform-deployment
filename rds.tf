resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = tolist(aws_subnet.private[*].id)
}

resource "aws_db_instance" "rds_instance" {
  engine                 = "mysql"
  skip_final_snapshot    = true
  instance_class         = "db.t2.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  identifier             = "${var.name}-db-instance"
  username               = var.rds_username
  password               = var.rds_password
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.handle_sg.id]
  }
}