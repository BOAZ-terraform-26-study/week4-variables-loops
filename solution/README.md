# solution: week4 정답 코드

`practice/`의 TODO ①~⑩을 전부 채운 상태입니다. 막혔을 때만 여세요.

| 파일 | 오늘의 포인트 |
|------|-------------|
| `backend.tf` | week3 버킷 재사용. `key`만 `week04/app/terraform.tfstate` 로 다릅니다 |
| `variables.tf` | `map(object({cidr, az}))` · `validation` 6개 · `my_ip` 의 `sensitive` |
| `locals.tf` | `name_prefix` · `merge()` 로 조립한 `common_tags` |
| `network.tf` | `aws_subnet.public` 과 `aws_route_table_association.public` 의 `for_each` |
| `compute.tf` | EC2 1대. `aws_subnet.public[var.primary_subnet_key].id` 로 배치 |
| `outputs.tf` | `for` 표현식 맵 2개 · `sensitive` output |

`practice/count-demo/`는 정답이 따로 없습니다. 채울 것이 없고 값을 지워보는 실습입니다.

```bash
cp example.tfvars terraform.tfvars   # project_name · my_ip 채우기
# backend.tf 의 bucket / dynamodb_table 을 본인 week3 값으로
terraform init && terraform plan      # Plan: 9 to add, 0 to change, 0 to destroy.
terraform apply                       # yes
terraform destroy                     # yes. 반드시
```

> [!CAUTION]
> 정답 코드도 apply하면 똑같이 과금됩니다. 시간당 $0.0190 입니다. `destroy`를 잊지 마세요.
