terraform {
  # 1.9.0 이상을 요구하는 이유가 이번 주에 하나 더 생겼습니다.
  # variable 의 validation 블록이 다른 변수를 참조할 수 있게 된 것이 1.9 부터입니다.
  # variables.tf 의 primary_subnet_key 검사가 그 기능을 씁니다.
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
