#### A-2 기록

by_count 세 줄을 그대로 옮겨 적기: terraform_data.by_count[0]
terraform_data.by_count[1]
terraform_data.by_count[2]
by_for_each 세 줄을 그대로 옮겨 적기: terraform_data.by_for_each["alpha"]
terraform_data.by_for_each["bravo"]
terraform_data.by_for_each["charlie"]
"bravo" 삭제 후 plan 마지막 줄: Plan: 1 to add, 0 to change, 3 to destroy.
교체(-/+)되는 by_count의 주소와 그 주소에서 바뀌는 값: Changes to Outputs:
  ~ count_addresses    = [
        "terraform_data.by_count[0] = alpha",
      - "terraform_data.by_count[1] = bravo",
      - "terraform_data.by_count[2] = charlie",
      + (known after apply),
  ]

by_for_each 쪽에서 손대는 것은 몇 개이고 무엇인가: 삭제된 terraform_data.by_for_each["bravo"] 하나

---

#### A-6 기록

- 일부러 넣은 잘못된 값: `terraform plan -var 'primary_subnet_key=b'`
- 오류 첫 줄: `Error: Invalid value for variable`
- 내가 적은 `error_message`가 그대로 나왔는가: `primary_subnet_key 는 다음 중 하나여야 합니다: a, c`
- 이 오류는 plan 이 시작되기 전에 났는가, apply 도중에 났는가: `plan 도중, apply 전`

---

#### B-5 기록

- `plan` 마지막 줄: `Plan: 9 to add, 0 to change, 0 to destroy.`
- `state list` 줄 수: `11` (리소스 `9` + 데이터 소스 `2`)
- `aws_subnet.public`으로 시작하는 두 줄: `aws_route_table_association.public["a"]
aws_route_table_association.public["c"]`
- `terraform output subnet_ids`가 찍은 key 두 개: `"a","c"`
- `terraform output ssh_source_cidr`이 화면에 찍은 값: `<sensitive>`

---

#### B-6 기록

- S3 객체 키 전체: `week04/app/terraform.tfstate`
- `terraform output`과 `terraform output -raw`에서 값이 각각 보였는가: `o` / `o`
- state 안에 평문으로 들어 있었는가: `o`
- `sensitive`가 막는 것과 못 막는 것을 한 문장으로: `Terraform이 알아서 값을 뿌리는 곳(plan/apply 요약, terraform output 전체 목록)만 가려주고, 사용자가 이름을 찍어 꺼내는 곳(terraform output <이름>, -json)이나 state 파일 안의 평문은 못 막는다.`

---

#### B-7 기록

- 세 번째 key 추가 후 plan 마지막 줄: `Plan: 2 to add, 0 to change, 0 to destroy.`
- 기존 `["a"]` · `["c"]`에 `~`나 `-/+`가 붙었는가: `x`
- A-2의 `count` 쪽 결과와 비교해 한 문장: `key가 다르면 건드리지 않는다`