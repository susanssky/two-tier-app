resource "aws_security_group" "lb" {
  vpc_id = aws_vpc.vpc.id
  name   = "${local.project_name}-lb-sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [local.anyone_access_ip]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.anyone_access_ip]
  }
  tags = {
    Name = "${local.project_name}-lb-sg"
  }
}


resource "aws_security_group" "rds" {
  vpc_id = aws_vpc.vpc.id
  name   = "${local.project_name}-rds-sg"
  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    # cidr_blocks     = [local.anyone_access_ip]
    security_groups = [aws_security_group.ec2.id, aws_security_group.lb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.anyone_access_ip]
  }
  tags = {
    Name = "${local.project_name}-rds-sg"
  }
}

resource "aws_security_group" "ec2" {
  vpc_id = aws_vpc.vpc.id
  name   = "${local.project_name}-ec2-sg"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.anyone_access_ip] // if hope only me come, write my ip/32
  }
  ingress {
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = [local.anyone_access_ip]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.anyone_access_ip]

  }
  tags = {
    Name = "${local.project_name}-ec2-sg"
  }
}

