# ---------------------------------------------------------------------------
# network.tf: VPC / subnet(N개) / IGW / route table / association(N개)
#
# week3 과 리소스 종류는 같습니다. 달라진 것은 서브넷과 연결이 for_each 로
# 맵의 항목 수만큼 늘어난다는 점 하나입니다. 지금은 항목이 2개라 리소스 7개가 됩니다.
# ---------------------------------------------------------------------------

# 이 계정에서 실제로 쓸 수 있는 AZ 목록을 AWS에 물어본다.
# week4 에서는 AZ 를 var.subnets 에 직접 적기 때문에, 이 데이터 소스는
# 만드는 데 쓰지 않고 아래 precondition 에서 "그 AZ 가 이 계정에 있는가"를 검사하는 데 쓴다.
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr # week3 까지 "10.0.0.0/16" 이 박혀 있던 자리
  enable_dns_support   = true
  enable_dns_hostnames = true

  # Project · Study · Week · ManagedBy · Purpose 는 provider 의 default_tags 가 붙인다.
  # 여기에는 리소스마다 달라지는 Name 만 적는다.
  tags = { Name = "${local.name_prefix}-vpc" }
}

# ---------------------------------------------------------------------------
# for_each 로 서브넷을 맵 항목 수만큼 만든다.
#
#   each.key   = 맵의 key    ("a", "c")
#   each.value = 맵의 값     ({ cidr = "...", az = "..." })
#
# state 에는 인덱스가 아니라 key 로 기록된다.
#   aws_subnet.public["a"]      aws_subnet.public["c"]
# 그래서 맵에서 항목 하나를 지워도 나머지 항목의 주소가 밀리지 않는다.
# count 였다면 [0] [1] 로 기록되고, 가운데를 지우는 순간 뒤가 전부 재생성된다.
# 이 차이는 practice/count-demo 에서 직접 본다.
# ---------------------------------------------------------------------------
resource "aws_subnet" "public" {
  for_each = var.subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  # 이 서브넷에서 뜨는 인스턴스는 퍼블릭 IPv4를 자동으로 받는다.
  # 주의: 퍼블릭 IPv4 자체가 시간당 $0.005 과금된다(2024-02-01부터).
  # 서브넷이 2개여도 인스턴스가 1대라서 퍼블릭 IP도 1개다.
  map_public_ip_on_launch = true

  tags = { Name = "${local.name_prefix}-public-${each.key}" }

  # AZ 이름은 계정마다 물리 AZ에 다르게 매핑되고, 오래된 계정은 특정 AZ를 못 쓸 수도 있다.
  # var.subnets 에 AZ를 손으로 적었으므로, 그 이름이 이 계정에 실제로 있는지 plan 단계에서 검사한다.
  # 이 블록이 없으면 apply 중에 InvalidParameterValue 로 죽는다.
  lifecycle {
    precondition {
      condition     = contains(data.aws_availability_zones.available.names, each.value.az)
      error_message = "subnets[\"${each.key}\"].az 가 이 계정에서 쓸 수 없는 AZ입니다: ${each.value.az}"
    }
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "${local.name_prefix}-igw" }
}

# 라우트 테이블은 서브넷마다 만들지 않는다. 서브넷 2개가 같은 테이블 하나를 공유한다.
# for_each 를 쓸 자리와 안 쓸 자리를 가르는 기준은 "항목마다 값이 달라지는가" 이다.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = { Name = "${local.name_prefix}-rt-public" }
}

# ---------------------------------------------------------------------------
# 연결도 서브넷 수만큼 필요하다. 여기서는 var.subnets 가 아니라
# aws_subnet.public 자체를 for_each 에 넣는다.
#
# 리소스 맵을 for_each 에 넣으면 key 는 그대로 유지되고 each.value 가 서브넷 객체가 된다.
#   each.key   = "a"
#   each.value = aws_subnet.public["a"] 객체
# var.subnets 를 다시 순회해도 결과는 같지만, 이렇게 쓰면 서브넷을 먼저 만들라는
# 참조가 자연스럽게 생기고 key 가 어긋날 일이 없다.
# ---------------------------------------------------------------------------
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------------------------------------
# 여기에 NAT Gateway / Elastic IP 를 추가하지 마세요.
# 특히 for_each 를 배운 직후라 서브넷마다 NAT 를 하나씩 붙이고 싶어지는데,
# NAT Gateway 는 시간당 과금 + 데이터 처리 과금이고 프리티어가 없습니다.
# for_each 를 잘못 건 리소스는 요금도 항목 수만큼 곱해집니다.
# ---------------------------------------------------------------------------
