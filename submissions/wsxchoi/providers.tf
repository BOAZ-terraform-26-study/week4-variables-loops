# 자격증명은 여기 넣지 않습니다. aws configure / 환경변수로만 주입.
provider "aws" {
  region = var.region

  # week3 에서는 이 안에 태그 다섯 줄을 직접 적었습니다.
  # 이번 주에는 그 조립을 locals.tf 의 common_tags 한 곳으로 옮겼습니다.
  # default_tags 는 이 스택이 만드는 모든 리소스에 이 맵을 자동으로 붙입니다.
  #
  # Purpose = workload 표시가 scripts/check-leftover.sh 에서
  # "오늘 지워야 하는 것(workload)"과 "week3 이 남겨둔 state 저장소(terraform-state)"를
  # 갈라내는 기준입니다. 실습워크북 C-3.
  default_tags {
    tags = local.common_tags
  }
}
