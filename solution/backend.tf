# week3 에서 만든 S3 버킷과 DynamoDB 테이블을 그대로 씁니다. 새로 만들지 않습니다.
# 달라지는 것은 key 한 줄뿐입니다. week03/app/... 이 아니라 week04/app/... 입니다.
# 같은 버킷 안에서 key 가 다르면 서로 다른 state 입니다. week3 의 state 를 덮어쓰지 않습니다.
#
# 아래 bucket 과 dynamodb_table 은 예시입니다. week3 의 bootstrap 스택에서
# `terraform output -raw backend_config` 로 출력한 본인 값으로 바꾸세요.
#
# 여기에 var.project_name 을 쓸 수 없습니다. init 이 backend 를 가장 먼저 초기화하고
# 그 시점에는 변수가 아직 평가되지 않았기 때문입니다. week3 개념워크북 4번.
#
# init 할 때 dynamodb_table 이 deprecated 라는 경고가 뜹니다. 정상입니다.
terraform {
  backend "s3" {
    bucket         = "boaz26-w3-kdh1834-tfstate"
    key            = "week04/app/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "boaz26-w3-kdh1834-tflock"
    encrypt        = true
  }
}
