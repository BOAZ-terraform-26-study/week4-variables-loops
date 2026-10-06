# 복사해서 terraform.tfvars 로 저장하고 값을 채우세요 (terraform.tfvars는 커밋 금지).
region = "ap-northeast-2"

# week4 용 이름을 새로 정합니다. week3 의 project_name 과 달라도 됩니다.
# backend 의 버킷 이름은 week3 값 그대로이고, 그것은 backend.tf 에 따로 적습니다.
project_name = "CHANGE-ME" # 예: boaz26-w4-kdh1834

# curl -4 ifconfig.me 결과를 그대로. /32 를 붙이지 마세요 (코드가 붙입니다).
my_ip = "CHANGE-ME"

instance_type = "t3.micro"

# 아래 셋은 default 가 있어서 적지 않아도 됩니다.
# 값을 바꿔보고 싶을 때만 주석을 푸세요.
#
# vpc_cidr = "10.0.0.0/16"
#
# subnets = {
#   a = { cidr = "10.0.1.0/24", az = "ap-northeast-2a" }
#   c = { cidr = "10.0.2.0/24", az = "ap-northeast-2c" }
# }
#
# primary_subnet_key = "a"
#
# extra_tags = { Owner = "kdh1834" }
