# ---------------------------------------------------------------------------
# backend.tf: 이 스택의 state를 어디에 둘지 정하는 파일
#
# week3 에서 만든 S3 버킷과 DynamoDB 테이블을 그대로 씁니다. 새로 만들지 않습니다.
# 달라지는 것은 key 한 줄뿐입니다. 같은 버킷 안에서 key 가 다르면 서로 다른 state 라서,
# week3 의 state 를 덮어쓰지 않습니다. key 는 이미 채워져 있으니 건드리지 마세요.
#
# 여기에 var.project_name 을 쓸 수 없습니다. init 이 backend 를 가장 먼저 초기화하고
# 그 시점에는 변수가 아직 평가되지 않았기 때문입니다. week3 개념워크북 4번.
# 그래서 버킷 이름을 손으로 적습니다.
#
# TODO(A-3) ①: bucket 과 dynamodb_table 의 CHANGE-ME 를 본인 week3 값으로 바꾸세요.
#   week3 리포의 practice/bootstrap 에서 아래를 실행하면 다섯 줄이 그대로 나옵니다.
#     terraform output -raw backend_config
#   그 출력에서 key 만 week04/app/terraform.tfstate 로 바꿔 쓰면 됩니다.
# ---------------------------------------------------------------------------

terraform {
  backend "s3" {
    bucket         = "CHANGE-ME-tfstate" # 예: boaz26-w3-kdh1834-tfstate
    key            = "week04/app/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "CHANGE-ME-tflock" # 예: boaz26-w3-kdh1834-tflock
    encrypt        = true
  }
}
