# ---------------------------------------------------------------------------
# compute.tf: AMI 데이터 소스 / security group / EC2  (리소스 2개)
#
# 서브넷이 2개로 늘어도 EC2는 1대입니다. for_each 를 여기에 걸지 마세요.
# 인스턴스는 항목 수만큼 요금이 곱해집니다.
# ---------------------------------------------------------------------------

# 이름 패턴을 'al2023-ami-2023.*' 로 시작까지 고정하는 이유는 week3 개념워크북 15번에 있습니다.
# 느슨하게 두면 ECS 전용 AMI(루트 볼륨 30GiB)가 후보에 들어와 apply 가 실패합니다.
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"] # instance_type(t3.micro)과 반드시 일치해야 한다
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

# 주의: 아래 인라인 ingress/egress 블록과, 별도 리소스인
#      aws_vpc_security_group_ingress_rule 을 절대 섞어 쓰지 마세요. 서로의 규칙을 지웁니다.
resource "aws_security_group" "web" {
  name        = "${local.name_prefix}-web-sg"
  description = "boaz w4 lab: SSH from my IP only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    # var.my_ip 가 sensitive 이므로, 이 규칙은 plan 출력에서 (sensitive value) 로 가려진다.
    # 값이 안 보이는 것이지 안 들어간 것이 아니다. 0.0.0.0/0 으로 열지 마세요.
    cidr_blocks = ["${var.my_ip}/32"]
  }

  egress {
    description = "all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # 모든 프로토콜
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name_prefix}-web-sg" }
}

# ---------------------------------------------------------------------------
# 여기에 for_each 를 붙이지 마세요.
#   서브넷을 2개로 늘려도 비용은 $0 입니다. 서브넷이 무료이기 때문입니다.
#   EC2 를 2대로 늘리면 시간당 $0.0190 이 $0.0380 이 됩니다. 정확히 두 배입니다.
#   오늘 배우는 것은 반복이고, 증설이 아닙니다.
# 여러 서브넷 중 어디에 놓을지는 for_each 가 아니라 맵 인덱싱으로 고릅니다.
# ---------------------------------------------------------------------------
resource "aws_instance" "web" {
  ami           = data.aws_ami.al2023.id
  instance_type = var.instance_type

  # 서브넷이 맵이므로 하나를 key 로 골라야 한다. 번호가 아니라 이름으로 고른다.
  # var.primary_subnet_key 에 없는 key 를 넣으면 variables.tf 의 validation 이 먼저 걸러낸다.
  #
  # values(aws_subnet.public)[0] 을 쓰지 않는 이유가 오늘 주제와 같다.
  # values() 의 순서는 맵 key 정렬을 따르므로, 나중에 key "b" 를 추가하면
  # [0] 이 가리키는 서브넷이 조용히 바뀌면서 인스턴스가 통째로 재생성된다.
  subnet_id              = aws_subnet.public[var.primary_subnet_key].id
  vpc_security_group_ids = [aws_security_group.web.id]

  # 퍼블릭 IP는 서브넷의 map_public_ip_on_launch 하나로만 통제한다.

  # 루트 볼륨을 명시해 비용을 눈으로 확인한다. 8GiB gp3 ≈ $0.73/월.
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true
  }

  # IMDSv2 강제. AL2023 기본값이지만 코드에 의도를 남긴다.
  metadata_options {
    http_tokens = "required"
  }

  tags = { Name = "${local.name_prefix}-web" }
}

# ---------------------------------------------------------------------------
# 키페어(aws_key_pair)를 만들지 않습니다 = 오늘도 SSH로 접속하지 않습니다.
# 성공 기준은 instance_state = running + 퍼블릭 IP 할당입니다. week2·week3 과 같습니다.
# ---------------------------------------------------------------------------
