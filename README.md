# Week 4. 변수와 반복 (variables / locals / for_each) `[대면]`

> **강의자료:** [개념워크북](./lecture/개념워크북.pdf) · [실습워크북](./lecture/실습워크북.pdf)
> 개념워크북은 예습으로 읽고, 실습워크북을 위에서 아래로 따라가며 진행합니다. 원본은 같은 폴더의 `.md` 파일입니다.

> 이번 주가 끝나면: 코드에 박아둔 값을 **variable 과 locals 로 걷어내고**, `for_each`로 서브넷 2개를 만들고, 같은 일을 `count`로 했을 때 무엇이 밀리는지 눈으로 확인합니다.

## 0. 메타 정보
| 항목 | 내용 |
|------|------|
| 일시 | 2026-MM-DD · 60분 |
| 방식 | **대면** (멘토링 정기모임 병행) |
| 선행 | week3 완료. week3에서 만든 S3 버킷과 DynamoDB 테이블을 그대로 재사용 |
| 산출물 | `submissions/{github-id}/` PR · **과제③ 출제** |

## 1. 학습 목표
- [ ] `variable`의 타입(string / map / object)과 `default` · `validation` · `sensitive`를 쓸 수 있습니다
- [ ] `locals`로 공통 값을 계산하고 `merge()`로 태그를 합칠 수 있습니다
- [ ] `for_each`로 map 을 순회해 리소스 N개를 만들 수 있습니다
- [ ] `for_each`가 `count`보다 안전한 이유를 인덱스 밀림으로 설명할 수 있습니다
- [ ] `for` 표현식으로 output 을 맵 형태로 낼 수 있습니다

## 2. 사전 예습 (필수)
- `lecture/개념워크북.md`의 Part 0 · 1 · 2 · 5를 읽어 오세요. 라이브에서는 Part 3 · 4 · 6만 짚습니다.
- HashiCorp: [Input Variables](https://developer.hashicorp.com/terraform/language/values/variables) · [for_each](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each) (15분)
- 예습 체크: "list 로 `count`를 쓰다가 가운데 원소를 지우면 무엇이 재생성되는지" 한 문장으로 말할 수 있습니다. 답은 개념워크북 11번입니다.

> [!IMPORTANT]
> **세션 시작 전에 각자 확인하세요.** week3에서 만든 버킷과 테이블이 살아 있어야 오늘 실습이 시작됩니다. `{본인-github-id}` 자리는 직접 채우세요.
> ```bash
> aws s3api head-bucket --bucket "boaz26-w3-{본인-github-id}-tfstate" && echo "OK: 버킷 있음"
> aws dynamodb describe-table --region ap-northeast-2 \
>   --table-name "boaz26-w3-{본인-github-id}-tflock" --query 'Table.TableStatus' --output text
> ```
> 실패하면 week3 리포의 `bootstrap` 스택을 다시 apply 해야 합니다. 세션 중에 하기에는 시간이 모자라니 미리 알려주세요.

## 3. 진행 타임박스 (60분)
| 시간 | 구성 | 내용 |
|------|------|------|
| 0~5분 | 회고 | 랜덤 지목 |
| 5~10분 | 과제② 리뷰 | 대표 PR 화면 공유 |
| 10~55분 | 실습 45분 | Block A 워크스루 18분 · Block B 각자 20분 · Block C 정리 7분 |
| 55~60분 | 마무리 | 과제③ 브리핑, 5주차 예고 |

## 4. 실습 개요: week3가 넘긴 하드코딩 회수

지난주에 미뤄둔 것을 오늘 자리로 돌려놓습니다.

| week3에서 이렇게 두었습니다 | 오늘 회수하는 자리 |
|---------------------------|------------------|
| `t3.micro` · `10.0.1.0/24`가 코드에 박혀 있습니다 | `variable`로 뺍니다 |
| 같은 이름 조립식을 여러 파일에 반복했습니다 | `locals` 한 곳에 모읍니다 |
| `project_name` 하나로 리소스 이름을 조립했습니다 | 이름 목록이 여럿이면 `for_each` 입니다 |
| output 을 사람이 읽어 옮겨 적었습니다 | `for` 표현식으로 맵을 냅니다 |
| `backend.tf`에 버킷 이름을 손으로 적었습니다 | backend 는 변수를 못 받습니다. 여기까지가 한계입니다 |

작업 폴더는 두 개입니다.

```
practice/          # 리소스 9개 + 데이터 소스 2개. state 는 week3 의 S3 버킷
 └─ count-demo/    # 무과금 샌드박스. 내장 terraform_data 만 씁니다
```

`count`와 `for_each`의 차이는 AWS 가 아니라 샌드박스에서 먼저 봅니다. `terraform_data`는 Terraform 내장 리소스라 자격증명도 필요 없고 과금도 없습니다.

```bash
cd practice/count-demo
terraform init && terraform apply    # 6 added
terraform state list                 # 위 셋은 [0][1][2], 아래 셋은 ["alpha"]...
#   main.tf 의 names 에서 가운데 "bravo" 를 지운 뒤
terraform plan                       # Plan: 1 to add, 0 to change, 3 to destroy.
```

그다음 app 스택입니다.

```bash
cd ..
cp example.tfvars terraform.tfvars   # project_name · my_ip 채우기. 커밋 금지
#   backend.tf 의 CHANGE-ME 두 곳을 week3 버킷/테이블 이름으로. key 는 건드리지 않기
terraform init                       # week3 버킷, key = "week04/app/terraform.tfstate"
#   TODO ②~⑩ 채우기
terraform plan                       # "Plan: 9 to add, 0 to change, 0 to destroy."
terraform apply                      # yes
terraform state list                 # 11줄 (리소스 9 + 데이터 소스 2)
terraform output                     # subnet_ids 가 맵으로 나옵니다
terraform destroy                    # yes
../scripts/check-leftover.sh         # Purpose=workload 전부 0
```

> [!CAUTION]
> `backend.tf`의 `key`는 `week04/app/terraform.tfstate`입니다. week3의 `week03/app/...`을 그대로 두면 지난주 state 를 인수합니다. bucket 과 dynamodb_table 만 week3 것을 씁니다.
>
> 첫 `plan`이 `9 to add`가 아니면 apply 하지 말고 멈추세요. 코드로 막을 수 없는 자리라 이 확인이 유일한 방어선입니다.

## 5. 체크포인트 (DoD)
- [ ] count-demo 에서 `Plan: 1 to add, 0 to change, 3 to destroy.` 재현
- [ ] `plan`이 `Plan: 9 to add, 0 to change, 0 to destroy.`
- [ ] `state list` 11줄. 서브넷 주소가 `aws_subnet.public["a"]` 형태
- [ ] `t3.micro` · CIDR · AZ 가 리소스 블록에서 사라지고 variable 또는 locals 로 이동
- [ ] 태그가 `merge()`로 조립되어 `default_tags`로 한 번에 붙습니다
- [ ] `output`이 `for` 표현식으로 맵을 냅니다
- [ ] `my_ip`가 `sensitive`라 plan 출력에서 `(sensitive value)`로 가려집니다
- [ ] **`destroy` 완료.** `state list` 빈 출력과 `Purpose=workload` 0을 각각 확인
- [ ] count-demo 도 `destroy` (`6 destroyed`)
- [ ] week3의 S3와 DynamoDB는 지우지 않았습니다

## 6. 트러블슈팅 FAQ
| 증상 | 원인 | 해결 |
|------|------|------|
| `Invalid for_each argument` | list 를 그대로 넣음 | map 을 쓰거나 `toset(list)`로 감싸기 |
| `for_each` 값을 apply 전에 못 정한다는 오류 | key 에 리소스 속성을 씀 | key 는 변수와 상수로만. 값 쪽에는 써도 됩니다 |
| `Invalid index` | `primary_subnet_key`가 `subnets`에 없음 | 교차 참조 `validation` 확인 (실습 A-5) |
| `Error: Invalid value for variable` | `validation` 위반 | `error_message`가 요구하는 형식으로 값 수정 |
| `Error: Resource precondition failed` | `subnets`의 `az`가 이 계정에 없음 | `aws ec2 describe-availability-zones --region ap-northeast-2` |
| `Output refers to sensitive values` | `sensitive` 변수를 쓰는 output 에 표시 없음 | 그 output 에도 `sensitive = true` |
| `zsh: no matches found` | 주소의 대괄호를 셸이 해석 | `terraform state show 'aws_subnet.public["a"]'` |
| init 에서 `S3 bucket ... does not exist` | week3 버킷 이름 오타 또는 bootstrap 없음 | week3 `terraform output -raw backend_config`와 대조 |
| `plan`이 9가 아닌 이상한 숫자 | `backend.tf`의 `key`가 week3 것 | apply 금지. `key`를 `week04/app/...`으로 |
| `Error acquiring the state lock` | 동시 실행 또는 비정상 종료 | 대기. 아무도 없으면 `terraform force-unlock <LOCK_ID>` |
| `dynamodb_table` deprecated 경고 | Terraform 1.10+ 는 `use_lockfile` 권장 | 정상입니다. week3 개념워크북 9번 |

## 7. 심화 도전과제 (심화 ⭐)
- L2: `-backend-config=backend.hcl` 파일로 backend 값 분리 (실습워크북 B-8)
- L2: `terraform console`로 `merge()`의 우선순위와 `for` 표현식 확인 (실습워크북 B-9)
- L3: 이미 apply 한 `count` 리소스를 재생성 없이 `for_each`로 옮기기. 과제③의 본문입니다

## 8. 다음 주 예고 & 준비물

| 오늘 본 것 | Week5에서 문제가 되는 지점 |
|-----------|--------------------------|
| `variables.tf` 하나에 변수 8개가 모였습니다 | 다른 폴더에서 쓰려면 복사해야 합니다. 복사본은 곧 원본과 어긋납니다 |
| `subnet_ids`를 맵으로 꺼냈습니다 | 지금은 사람이 화면으로 읽습니다. 코드가 코드에게 넘기려면 받는 쪽이 필요합니다 |
| `for_each`로 서브넷을 2개로 늘렸습니다 | 리소스 하나가 아니라 리소스 묶음을 여러 벌 만들려면 어디에 걸까요 |
| `local.common_tags`가 이 폴더 안에서만 보입니다 | `locals`는 폴더 경계를 넘지 않습니다 |
| `backend.tf`에 버킷 이름을 또 손으로 적었습니다 | dev 와 prod 를 같은 코드로 만들려면 `key`만 달라야 합니다 |

- Week5(대면): 모듈화. 오늘 변수화한 코드를 재사용 가능한 모듈로 추출합니다
- 예습: `module` 블록, `source`, 모듈의 input 과 output

---

> [!CAUTION]
> **비용.** app 스택은 시간당 $0.0190입니다. EC2 `t3.micro` $0.0130 · 퍼블릭 IPv4 1개 $0.0050 · EBS `gp3` 8GiB $0.0010을 합한 값이고 서울 리전 기준입니다. destroy 를 잊고 한 달 두면 약 $13.87입니다.
> VPC · 서브넷 · IGW · 라우트 테이블 · 연결 · 시큐리티 그룹은 $0 이라, 서브넷이 2개로 늘어도 요금은 그대로입니다. count-demo 도 $0 입니다.
> **EC2는 1대로 고정합니다.** `for_each`를 EC2 · NAT Gateway · Elastic IP 에 걸면 요금이 항목 수만큼 곱해집니다.
> stop 은 destroy 가 아닙니다. 인스턴스를 멈춰도 EBS 8GiB의 월 $0.73은 계속 나갑니다.
>
> **올리면 안 되는 값.** 본인 공인 IP · AWS 계정번호 12자리 · 액세스 키 · `terraform.tfvars` · `terraform.tfstate` · `.pem` 파일. 마스킹 절차는 실습워크북 C-4에 있습니다.

> **제출.** `submissions/{본인-github-id}/`에 브랜치 `week4/{github-id}`로 PR 을 올립니다. `practice/`는 직접 고쳐 올리지 마세요. 머지되는 순간 다음 사람의 빈칸이 사라집니다.
