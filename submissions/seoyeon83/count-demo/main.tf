# ---------------------------------------------------------------------------
# count-demo: 과제③ 최종본. count 로 apply 되어 있던 리소스를 재생성 없이 for_each 로 옮깁니다.
#
# 여기에는 AWS 리소스가 하나도 없습니다. provider 도 자격증명도 필요 없습니다.
# terraform_data 는 Terraform 에 내장된 리소스라서 apply 해도 계정에 아무것도 안 생기고
# 요금도 발생하지 않습니다. state 도 이 폴더의 로컬 파일에 남습니다.
#
# state-before.txt -> plan-naive.txt -> plan-fixed.txt -> state-after.txt 순서는
# assignment/ASSIGNMENT.md 를 따랐습니다.
# ---------------------------------------------------------------------------

terraform {
  required_version = ">= 1.9.0"
}

variable "names" {
  description = "count 로 만들었다가 for_each 로 옮길 목록"
  type        = list(string)
  default     = ["alpha", "bravo", "charlie"]
}

# count 시절의 주소를 for_each 의 key 주소로 그대로 인수합니다.
# 이 블록이 없으면 위 3번처럼 대상이 통째로 destroy 되고 create 됩니다.
moved {
  from = terraform_data.by_count[0]
  to   = terraform_data.by_count["alpha"]
}

moved {
  from = terraform_data.by_count[1]
  to   = terraform_data.by_count["bravo"]
}

moved {
  from = terraform_data.by_count[2]
  to   = terraform_data.by_count["charlie"]
}

resource "terraform_data" "by_count" {
  for_each = toset(var.names)

  triggers_replace = each.key
  input            = each.key
}
