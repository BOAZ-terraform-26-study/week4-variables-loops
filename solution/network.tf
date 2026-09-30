# ---------------------------------------------------------------------------
# network.tf: VPC / subnet(N개) / IGW / route table / association(N개)
#
# week3 과 리소스 종류는 같습니다. 달라진 점은 서브넷과 연결을 for_each 로 생성하므로
# 변수의 항목 수만큼 늘어난다는 것입니다. 지금은 항목이 2개라 리소스 7개가 됩니다.
# ---------------------------------------------------------------------------

# 이 계정에서 사용 가능한 가용 영역(AZ) 목록을 조회합니다.
# week4 에서는 AZ 를 var.subnets 에 직접 입력하므로, 이 데이터 소스는
# 리소스 생성에 사용하지 않고 아래 precondition 에서 "그 AZ 가 이 계정에서 사용 가능한가"를 검증하는 데 사용합니다.
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr # week3 까지 "10.0.0.0/16" 이 직접 적혀 있던 자리
  enable_dns_support   = true
  enable_dns_hostnames = true

  # Project · Study · Week · ManagedBy · Purpose 는 provider 의 default_tags 가 붙입니다.
  # 여기에는 리소스마다 달라지는 Name 만 적습니다.
  tags = { Name = "${local.name_prefix}-vpc" }
}

# ---------------------------------------------------------------------------
# for_each 로 서브넷을 맵 항목 수만큼 생성합니다.
#
#   each.key   = 맵의 key    ("a", "c")
#   each.value = 맵의 값     ({ cidr = "...", az = "..." })
#
# state 에는 인덱스가 아니라 key 로 기록됩니다.
#   aws_subnet.public["a"]      aws_subnet.public["c"]
# 그래서 맵에서 항목 하나를 지워도 나머지 항목의 주소가 밀리지 않습니다.
# count 였다면 [0] [1] 로 기록되고, 가운데를 지우는 순간 뒤가 전부 재생성됩니다.
# 이 차이는 practice/count-demo 에서 직접 확인합니다.
# ---------------------------------------------------------------------------
resource "aws_subnet" "public" {
  for_each = var.subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  # 이 서브넷에서 생성되는 인스턴스는 퍼블릭 IPv4를 자동으로 받습니다.
  # 주의: 퍼블릭 IPv4 자체가 시간당 $0.005 과금됩니다(2024-02-01부터).
  # 서브넷이 2개여도 인스턴스가 1대라서 퍼블릭 IP도 1개입니다.
  map_public_ip_on_launch = true

  tags = { Name = "${local.name_prefix}-public-${each.key}" }

  # AZ 이름은 계정마다 물리 AZ에 다르게 매핑되고, 오래된 계정은 특정 AZ를 사용하지 못할 수 있습니다.
  # var.subnets 에 AZ를 직접 입력했으므로, 그 이름이 이 계정에서 실제로 사용 가능한지 plan 단계에서 검증합니다.
  # 이 블록이 없으면 apply 중에 InvalidParameterValue 오류로 실패합니다.
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

# 라우트 테이블은 서브넷마다 만들지 않습니다. 서브넷 2개가 같은 테이블 하나를 공유합니다.
# for_each 를 사용할 자리와 사용하지 않을 자리를 구분하는 기준은 "항목마다 값이 달라지는가"입니다.
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
# aws_subnet.public 자체를 for_each 에 넣습니다.
#
# 리소스 맵을 for_each 에 넣으면 key 는 그대로 유지되고 each.value 가 서브넷 객체가 됩니다.
#   each.key   = "a"
#   each.value = aws_subnet.public["a"] 객체
# var.subnets 를 다시 순회해도 결과는 같지만, 이렇게 쓰면 서브넷을 먼저 만들라는
# 참조가 자연스럽게 생기고 key 가 어긋날 일이 없습니다.
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
