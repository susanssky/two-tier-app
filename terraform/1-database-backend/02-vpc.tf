resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true //for RDS
  tags = {
    Name = "${local.project_name}-vpc"
  }
}
