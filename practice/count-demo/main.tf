# ---------------------------------------------------------------------------
# count-demo: count 와 for_each 의 차이를 눈으로 보는 무과금 샌드박스입니다.
#
# 여기에는 AWS 리소스가 하나도 없습니다. provider 도 자격증명도 필요 없습니다.
# terraform_data 는 Terraform 에 내장된 리소스라서 apply 해도 계정에 아무것도 안 생기고
# 요금도 발생하지 않습니다. state 도 이 폴더의 로컬 파일에 남습니다.
#
# 실습워크북 A-2 에서 씁니다. 아래 names 에서 "bravo" 를 지우고 plan 을 보세요.
# ---------------------------------------------------------------------------

terraform {
  required_version = ">= 1.9.0"
}

variable "names" {
  description = "가운데 항목을 지워보기 위한 목록. A-2 에서 bravo 를 지웁니다"
  type        = list(string)
  default     = ["alpha", "bravo", "charlie"]
}

# ---------------------------------------------------------------------------
# count: 리스트의 인덱스로 관리됩니다.
#   terraform_data.by_count[0]  [1]  [2]
# count.index 는 0 부터 시작하는 정수입니다. 이름이 아니라 자리 번호입니다.
#
# triggers_replace 는 값이 바뀌면 리소스를 교체(destroy 후 create)하게 만듭니다.
# 실제 인프라에서 "이 속성이 바뀌면 재생성된다"에 해당하는 자리를 흉내 낸 것입니다.
# ---------------------------------------------------------------------------
resource "terraform_data" "by_count" {
  count = length(var.names)

  triggers_replace = var.names[count.index]
  input            = var.names[count.index]
}

# ---------------------------------------------------------------------------
# for_each: set 의 값 자체가 key 가 됩니다.
#   terraform_data.by_for_each["alpha"]  ["bravo"]  ["charlie"]
#
# for_each 에는 map 이나 set 만 넣을 수 있습니다. list 를 그냥 넣으면
# `Invalid for_each argument` 가 나므로 toset() 으로 바꿔서 넣습니다.
# ---------------------------------------------------------------------------
resource "terraform_data" "by_for_each" {
  for_each = toset(var.names)

  triggers_replace = each.key
  input            = each.key
}

output "count_addresses" {
  description = "count 로 만든 것들의 주소. 인덱스입니다"
  value       = [for i, r in terraform_data.by_count : "terraform_data.by_count[${i}] = ${r.output}"]
}

output "for_each_addresses" {
  description = "for_each 로 만든 것들의 주소. key 입니다"
  value       = [for k, r in terraform_data.by_for_each : "terraform_data.by_for_each[\"${k}\"] = ${r.output}"]
}
