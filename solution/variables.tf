# ---------------------------------------------------------------------------
# variables.tf: 이번 주의 주인공입니다.
# week3 까지는 10.0.0.0/16 · 10.0.1.0/24 · t3.micro 가 코드에 박혀 있었습니다.
# 그 값들을 전부 여기로 올리고, 잘못된 값이 apply 까지 내려가지 못하게 validation 을 겁니다.
# ---------------------------------------------------------------------------

variable "region" {
  description = "리소스를 만들 리전 (스터디 공통: 서울)"
  type        = string
  default     = "ap-northeast-2"

  # 다른 리전에 만들면 scripts/check-leftover.sh 의 태그 조회가 못 찾습니다.
  # 지웠다고 생각한 인스턴스가 다른 리전에서 계속 과금되는 사고를 막습니다.
  validation {
    condition     = var.region == "ap-northeast-2"
    error_message = "이번 스터디는 서울(ap-northeast-2) 리전만 씁니다."
  }
}

variable "project_name" {
  description = "리소스 이름 접두어. week4 값을 새로 정합니다 (예: boaz26-w4-kdh1834)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{2,39}$", var.project_name))
    error_message = "project_name은 소문자·숫자·하이픈만, 3~40자여야 합니다. (예: boaz26-w4-kdh1834)"
  }
}

variable "my_ip" {
  description = "SSH를 허용할 본인 공인 IP. `curl -4 ifconfig.me` 결과. CIDR 아님, 순수 IP."
  type        = string

  # 이번 주에 붙인 한 줄입니다. 이 값이 plan 출력과 output 에서 (sensitive value) 로 가려집니다.
  # 스크린샷을 찍어 제출할 때 본인 공인 IP가 화면에 남지 않습니다.
  # 대신 이 값을 참조하는 output 에도 sensitive = true 를 붙여야 합니다. outputs.tf 참고.
  sensitive = true

  # 코드에서 "${var.my_ip}/32" 로 조립하므로, 여기에 이미 /32 가 붙어 있으면
  # "1.2.3.4/32/32" 가 되어 아래 cidrnetmask() 가 실패한다.
  validation {
    condition     = can(cidrnetmask("${var.my_ip}/32"))
    error_message = "my_ip는 1.2.3.4 처럼 순수 IPv4여야 합니다. /32나 CIDR을 넣지 마세요. (curl -4 ifconfig.me)"
  }
}

variable "instance_type" {
  description = "EC2 인스턴스 타입. week2·week3 과 같은 t3.micro(x86_64)를 씁니다."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t2.micro"], var.instance_type)
    error_message = "이번 실습은 t3.micro 또는 t2.micro 만 허용합니다 (과금 방지). t3.micro 는 서울 리전에서 시간당 $0.0130 이 과금되니, 프리티어를 믿지 말고 세션 끝에 반드시 destroy 하세요."
  }
}

variable "vpc_cidr" {
  description = "VPC 의 CIDR. week3 까지 network.tf 에 박혀 있던 10.0.0.0/16 을 여기로 올렸습니다."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr은 10.0.0.0/16 같은 CIDR 표기여야 합니다."
  }
}

# ---------------------------------------------------------------------------
# 오늘 서브넷을 반복 생성할 때 쓰는 변수입니다.
#
# week3 까지는 서브넷이 하나였고 CIDR 과 AZ 가 network.tf 에 직접 적혀 있었습니다.
# 지금은 "서브넷 여러 개"를 map 하나로 적습니다. 맵의 key 가 곧 리소스의 주소가 됩니다.
#   aws_subnet.public["a"]   aws_subnet.public["c"]
#
# 타입을 map(object({...})) 로 잡은 이유는 값이 두 개(cidr, az)이기 때문입니다.
# map(string) 이면 CIDR 하나만 담을 수 있고, AZ 를 넣을 자리가 없습니다.
# ---------------------------------------------------------------------------
variable "subnets" {
  description = "만들 퍼블릭 서브넷 목록. key 가 for_each 의 주소가 되므로 짧고 안 바뀌는 이름을 씁니다"

  type = map(object({
    cidr = string
    az   = string
  }))

  default = {
    a = { cidr = "10.0.1.0/24", az = "ap-northeast-2a" }
    c = { cidr = "10.0.2.0/24", az = "ap-northeast-2c" }
  }

  # 개수 상한입니다. 서브넷 자체는 무료지만, 맵에 항목을 늘리면
  # 나중에 이 맵을 쓰는 리소스(NAT Gateway 같은 것)를 붙였을 때 그대로 배수가 됩니다.
  validation {
    condition     = length(var.subnets) >= 1 && length(var.subnets) <= 3
    error_message = "subnets 는 1개 이상 3개 이하로 두세요. 이번 실습은 2개를 기본으로 합니다."
  }

  # 맵의 모든 값에 같은 검사를 겁니다. for 표현식이 여기서 한 번 나옵니다.
  validation {
    condition     = alltrue([for s in values(var.subnets) : can(cidrnetmask(s.cidr))])
    error_message = "subnets 의 cidr 은 10.0.1.0/24 같은 CIDR 표기여야 합니다."
  }

  # CIDR 이 겹치면 apply 한복판에서 InvalidSubnet.Conflict 로 죽습니다. 미리 막습니다.
  validation {
    condition     = length(distinct([for s in values(var.subnets) : s.cidr])) == length(var.subnets)
    error_message = "subnets 의 cidr 이 서로 겹치거나 중복됩니다. 항목마다 다른 대역을 쓰세요."
  }

  # region 을 바꾸고 az 를 안 바꾸는 실수를 잡습니다. 다른 변수를 참조하는 검사입니다.
  validation {
    condition     = alltrue([for s in values(var.subnets) : startswith(s.az, var.region)])
    error_message = "subnets 의 az 는 region(${var.region}) 으로 시작해야 합니다."
  }
}

variable "primary_subnet_key" {
  description = "EC2 를 놓을 서브넷. subnets 맵의 key 중 하나여야 합니다"
  type        = string
  default     = "a"

  # 다른 변수를 참조하는 validation 입니다. Terraform 1.9 부터 됩니다.
  # 이 검사가 없으면 오타를 냈을 때 "Invalid index" 라는 불친절한 오류를 보게 됩니다.
  validation {
    condition     = contains(keys(var.subnets), var.primary_subnet_key)
    error_message = "primary_subnet_key 는 다음 중 하나여야 합니다: ${join(", ", keys(var.subnets))}"
  }
}

variable "extra_tags" {
  description = "각자 덧붙이고 싶은 태그. locals.common_tags 에 merge 됩니다"
  type        = map(string)
  default     = {}
}
