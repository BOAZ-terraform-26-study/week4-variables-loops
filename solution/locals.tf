# ---------------------------------------------------------------------------
# locals.tf: 여러 곳에서 쓰는 조립식을 한 자리에 모읍니다.
#
# variable 과 locals 의 차이는 "밖에서 바꿀 수 있는가" 입니다.
#   variable : tfvars 나 -var 로 바깥에서 값을 넣습니다
#   locals   : 다른 값으로부터 계산합니다. 바깥에서 못 바꿉니다
# 그래서 project_name 은 variable 이고, 그것으로 조립한 name_prefix 는 locals 입니다.
# ---------------------------------------------------------------------------

locals {
  # week3 에서는 "${var.project_name}-vpc" 를 파일마다 반복해서 적었습니다.
  # 접두어 규칙이 바뀌면 그 모든 자리를 고쳐야 했습니다. 이름을 한 곳에서 만듭니다.
  name_prefix = var.project_name

  # merge 는 맵 여러 개를 하나로 합칩니다. 같은 key 가 겹치면 뒤에 온 쪽이 이깁니다.
  # 그래서 아래 리터럴 맵이 var.extra_tags 를 덮어씁니다.
  # Purpose = "workload" 를 학습자가 tfvars 에서 실수로 바꾸지 못하게 하는 순서입니다.
  # 순서를 뒤집으면 check-leftover.sh 의 분류가 깨집니다.
  common_tags = merge(
    var.extra_tags,
    {
      Project   = var.project_name
      Study     = "boaz-terraform-26"
      Week      = "4"
      ManagedBy = "terraform"
      Purpose   = "workload"
    }
  )
}
