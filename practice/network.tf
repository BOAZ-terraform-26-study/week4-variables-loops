resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags                 = merge(var.common_tags, { Name = "${var.project_name}-vpc" })
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-igw" }
}

# TODO(L1): public subnet 을 for_each = var.subnet_cidrs 로 반복 생성
#   each.key = AZ, each.value = CIDR
# resource "aws_subnet" "public" { ... }

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# TODO(L1): route table association 도 for_each 로 (subnet 마다)
# resource "aws_route_table_association" "public" { ... }
