# count-demo: 무과금 샌드박스

이 폴더는 **AWS를 건드리지 않습니다.** provider 도 자격증명도 필요 없고 요금도 나오지 않습니다.
`terraform_data`는 Terraform 내장 리소스라 `terraform init`이 아무것도 내려받지 않습니다.

`count`와 `for_each`가 리소스 주소를 어떻게 다르게 붙이는지, 목록 가운데를 지우면 무슨 일이 일어나는지를 여기서 봅니다. 실습워크북 A-2입니다.

```bash
terraform init
terraform apply          # yes. 6 added
terraform state list     # 위 셋은 [0][1][2], 아래 셋은 ["alpha"] ["bravo"] ["charlie"]

# main.tf 의 names 기본값에서 가운데 "bravo" 를 지운 뒤 (apply 하지 말 것)
terraform plan           # Plan: 1 to add, 0 to change, 3 to destroy.

# "bravo" 를 되돌려 놓고
terraform destroy        # yes. 6 destroyed
```

> [!IMPORTANT]
> 세션 끝에 `destroy` 하세요. 요금은 없지만 로컬 `terraform.tfstate`가 남아 제출물에 섞입니다.

과제③에서 이 폴더를 복사해 `count`를 `for_each`로 옮기는 연습을 합니다. [`assignment/ASSIGNMENT.md`](../../assignment/ASSIGNMENT.md)
