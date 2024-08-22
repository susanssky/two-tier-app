data "aws_availability_zones" "available" {
  state = "available"
}
# "names" = tolist([
#   "eu-west-2a",
#   "eu-west-2b",
#   "eu-west-2c",
# ])
resource "aws_subnet" "public" {
  count                   = local.subnet_number
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.${(count.index + 1) * 10}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.project_name}-public-subnet${count.index + 1}"
  }
}
resource "aws_subnet" "private" {
  count                   = local.subnet_number
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.${(count.index + 3) * 10}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "${local.project_name}-private-subnet${count.index + 1}"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${local.project_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${local.project_name}-public-rtb"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${local.project_name}-private-rtb"
  }
}


resource "aws_route_table_association" "rtb-public-subnet" {
  for_each       = { for idx, id in aws_subnet.public[*].id : idx => id }
  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "rtb-private-subnet" {
  for_each       = { for idx, id in aws_subnet.private[*].id : idx => id }
  subnet_id      = each.value
  route_table_id = aws_route_table.private.id
}

